-- Unicode example and using multi resolution fonts

application:setBackgroundColor(0x000000)

-- load font and enable filtering
local font = BMFont.new("hiragino.fnt", "hiragino.png", true)

-- create text
local text = BMTextField.new(font,"<#ffff00 ゲーム>をプレイ\n<#ff00ff ゲーム>をプレイ")

-- add to stage
stage:addChild(text)