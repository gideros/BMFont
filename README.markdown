### BMFont for Gideros Studio

The classes `BMFont` and `BMTextField` can be used to load and display BMFonts with Gideros Studio.

### Usage

    -- load font
    local font = BMFont.new("font.txt", "font.png")
    
    -- create text
    local text = BMTextField.new(font, "Hello Gideros!")
    
    -- add to stage
    stage:addChild(text)
    
    -- you can also change the text
    text:setText("Hello Giderans!")


These editors can be used to generate BMFonts:

* http://www.angelcode.com/products/bmfont/ (free, windows)
* http://glyphdesigner.71squared.com/ (commercial, mac os x)
* http://www.n4te.com/hiero/hiero.jnlp (free, java, multiplatform)
* http://slick.cokeandcode.com/demos/hiero.jnlp (free, java, multiplatform)
