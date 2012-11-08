-- check if string1 starts with string2
local function startsWith(string1, string2)
   return string1:sub(1, #string2) == string2
end

-- create table from a bmfont line
local function lineToTable(line)
	local result = {}
	for pair in line:gmatch("%a+=[-%d,]+") do
		local key = pair:match("%a+")
		local value = pair:match("[-%d,]+")
		
		if value:find(",") then -- handle special value like padding or spacing
			local data = {}
			value:gsub("([^,]+)", function(c) data[#data+1] = tonumber(c) end)
			result[key] = data
		else -- convert to number
			result[key] = tonumber(value)
		end
	end
	return result
end

-- this is our BMFont class
BMFont = {}
BMFont.__index = BMFont

-- and its new function
function BMFont.new(...)
	local self = setmetatable({}, BMFont)
	if self.init ~= nil and type(self.init) == "function" then
		self:init(...)
	end	
	return self
end

function BMFont:init(fontfile, imagefile, filtering)
	-- load font texture
	self.texture = Texture.new(imagefile, filtering)

	-- read glyphs from font.txt and store the information in chars and info table
	self.info = {}
	self.chars = {}
	self.kernings = {}
	file = io.open(fontfile, "rt")
	for line in file:lines() do	
		if startsWith(line, "char ") then
			local char = lineToTable(line)
			self.chars[char.id] = char
		elseif startsWith(line, "kerning ") then
			local kerning = lineToTable(line)
			self.kernings[kerning.first.."-"..kerning.second] = kerning.amount
		elseif startsWith(line, "info ") or startsWith(line, "common") then
			local data = lineToTable(line)
			for key,value in pairs(data) do 
				self.info[key] = value
			end
		end
	end
	io.close(file)
end

-- this is our BMTextField class
BMTextField = gideros.class(Sprite)

function BMTextField:init(font, str, wrapWidth, align)
	if not wrapWidth or wrapWidth < 0 then wrapWidth = 0 end
	if not align then align = "left" end
	
	self.font = font
	self.str = str
	self.wrapWidth = wrapWidth
	self.align = align
	self:createCharacters()
end

function BMTextField:setText(str)
	if self.str ~= str then
		self.str = str
		self:createCharacters()
	end
end

function BMTextField:createCharacters()
	-- remove all children
	for i=self:getNumChildren(),1,-1 do
		self:removeChildAt(i)
	end
	
	-- local vars
	local x = 0
	local y = 0
	local colorIndex = 0
	local isColoring = false
	
	-- calculate space width
	local spaceWidth = 0
	if self.font.chars[32] then
		spaceWidth = self.font.chars[32].xadvance + self.font.info.spacing[1]
	else 
		spaceWidth = self.font.info.base/3 + self.font.info.spacing[1]
	end
	
	-- colorize text if any
	local colors = {}
	self.str = string.gsub(self.str, "%b<>", function (word)
		local str = string.gsub(word, "#([%x]+) ", function (oct)
			local color = {}
			color.r = tonumber(oct:sub(1,2),16)/255
			color.g = tonumber(oct:sub(3,4),16)/255
			color.b = tonumber(oct:sub(5,6),16)/255
			colors[#colors+1] = color
			return ""
		end)
		return str
	end)
	
	-- create characters with unicode support and kernings
	local prevCharData = nil
	local charsInLine = {}; charsInLine.length = 0
	local currentWord = {}; currentWord.length = 0
	
	local function addToLine()
		for i,v in ipairs(currentWord) do
			charsInLine[#charsInLine+1] = v
		end
		charsInLine.length = x - spaceWidth
		currentWord = {}; currentWord.length = 0
	end
	
	local function process(char)
		local newLine = false
		local moveWord = false
		prevCharData = nil

		-- check overflow
		if (self.wrapWidth > 0) and (x  > self.wrapWidth) then
			newLine = true
			if #charsInLine > 0 then 
				moveWord = true
			else 
				addToLine()
			end
		elseif char == "\n" then 
			newLine = true
			addToLine()
		end
		
		-- set position to next line
		if newLine then 
			-- set align for current chars in line
			local diff = self.wrapWidth - charsInLine.length
			if self.align == "center" then
				diff = diff * 0.5
				for i,v in ipairs(charsInLine) do
					v:setX(v:getX()+diff)
				end
			elseif self.align == "right" then
				for i,v in ipairs(charsInLine) do
					v:setX(v:getX()+diff)
				end
			end
		
			-- reset coordinate for next line
			x = 0
			y = y + self.font.info.lineHeight + self.font.info.spacing[2] -- line height + vertical spacing
			prevCharData = nil
			charsInLine = {}; charsInLine.length = 0
		end
		
		-- move last word
		if moveWord then
			-- reposition the word
			if #currentWord > 0 then 
				local diffX = currentWord[1]:getX()
				local diffY = self.font.info.lineHeight + self.font.info.spacing[2]
				for i,v in ipairs(currentWord) do
					v:setPosition(v:getX()-diffX, v:getY()+diffY)
				end
			end
			x = currentWord.length
			addToLine()
		end
		
		-- spacing
		if (char == " ") and (moveWord or not newLine) then
			x = x + spaceWidth
			prevCharData = self.font.chars[32]
			addToLine()
		end
	end
	
	for char in string.gfind(self.str, "([%z\1-\127\194-\244][\128-\191]*)") do
		if char == " " or char == "\n" then -- handle space and new line
			process(char)
		elseif char == "<" then -- special case, start coloring text
			isColoring = true
			colorIndex = colorIndex + 1
		elseif char == ">" then -- special case, stop coloring text
			isColoring = false
		else -- create chars
			local c1, c2, c3, c4 = string.byte(char, 1, 4)
			local num = 0
			
			if c2 == nil then -- one bytes
				num = c1 
			elseif c3 == nil then -- two bytes
				num = c1 * 64 + c2 - 12416
			elseif c4 == nil then -- three bytes
				num = (c1 * 64 + c2) * 64 + c3 - 925824
			else -- four bytes
				num = ((c1 * 64 + c2) * 64 + c3) * 64 + c4 - 63447168
			end
			
			local charData = self.font.chars[num]
			if charData ~= nil then
				if prevChar then
					local kern = self.font.kernings[prevCharData.id.."-"..charData.id]
					if kern then 
						x = x + kern
					end
				end
			
				-- create a TextureRegion from each character and add them as a Bitmap
				local region = TextureRegion.new(self.font.texture, charData.x, charData.y, charData.width, charData.height)
				local bitmap = Bitmap.new(region)
				bitmap:setPosition(x + charData.xoffset, y + charData.yoffset)
				self:addChild(bitmap)
				currentWord[#currentWord+1] = bitmap
				
				-- color this char or not
				if isColoring then
					bitmap:setColorTransform(colors[colorIndex].r, colors[colorIndex].g, colors[colorIndex].b, 1)
				end
				
				local distance = charData.xadvance + self.font.info.spacing[1] -- xadvance + horizontal spacing
				x = x + distance
				currentWord.length = currentWord.length + distance
				prevCharData = charData
			end
		end
	end
	process(' ')
	process('\n')
end