-- Basic example, shows how to create plain text and using color to colorize texts
application:setBackgroundColor(0x000000)

-- load font and enable filtering
local font = BMFont.new("hobo.fnt", "hobo.png", true)

-- create text
local text = BMTextField.new(font, "Hello Gideros!")

-- add to stage
stage:addChild(text)

-- load another font
local anotherFont = BMFont.new("timesnewroman.fnt", "timesnewroman.png")

-- create colored text with line break and kerning
local coloredText = BMTextField.new(anotherFont, "i want this <#ff0000 red> and \ni want this <#0000ff blue> \nhow about <#00ff00 AV> kerning test")
coloredText:setY(100)

-- add to stage
stage:addChild(coloredText)
