-- Text wrap example

application:setBackgroundColor(0x000000)

-- load font and enable filtering
local font = BMFont.new("timesnewroman.fnt", "timesnewroman.png", true)

-- create text
local width = 200
local str = "lorem ipsum dolor sit amet lorem ipsum dolor sit amet lorem ipsum dolor sit amet awawa waw"
local text = BMTextField.new(font,str, width, "center")

local shape = Shape.new()
shape:beginPath()
shape:setFillStyle(Shape.SOLID, 0xffffff)
shape:lineTo(0,0)
shape:lineTo(width,0)
shape:lineTo(width,10)
shape:lineTo(0,10)
shape:endPath()
stage:addChild(shape)

-- add to stage
stage:addChild(text)