### BMFont for Gideros Studio

The classes `BMFont`, `BMTextField`, `BMTextWrap` can be used to load and display Angelcode format font (.fnt) with Gideros Studio.

### Features
* Write text using Angelcode format font
* Kerning
* Text wrapping with specified width
* Alignment

### Usage

    -- load font
    local font = BMFont.new("font.txt", "font.png")
    
    -- create text
    local text = BMTextField.new(font, "Hello Gideros!")
    
    -- add to stage
    stage:addChild(text)
    
    -- you can also change the text
    text:setText("Hello Giderans!")
    
    -- create wrapped text
    local textWrap = BTMTextWrap.new(font, "Lorem ipsum dolor sit amet", 100, "justify")
    
    -- add to stage
    stage:addChild(textWrap)
    
### Current Limitation
* Cannot use more than one font texture page
* Padding information is ignored
* Non-numeric value is ignored like font name or font texture path

### Editors
These visual editors can be used to generate BMFonts:

* http://www.angelcode.com/products/bmfont/ (free, windows)
* http://www.bmglyph.com/ (commercial, mac os x)
* http://glyphdesigner.71squared.com/ (commercial, mac os x)
* http://www.n4te.com/hiero/hiero.jnlp (free, java, multiplatform)
* http://slick.cokeandcode.com/demos/hiero.jnlp (free, java, multiplatform)
