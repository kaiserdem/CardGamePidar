import SwiftUI

extension Font {
    // Основний шрифт (NotoSerif-SemiCondensed-Italic)
    static func customRegular(size: CGFloat) -> Font {
        return Font.custom("Exo2-Regular", size: size)
    }
    
    // Жирний шрифт (NotoSerif-ExtraCondensed-BoldItalic)
    static func customBold(size: CGFloat) -> Font {
        return Font.custom("Exo2-ExtraBold", size: size)
    }
    
    // Стандартні розміри для зручності
    static var customLargeTitle: Font {
        return customBold(size: 34)
    }
    
    static var customTitle: Font {
        return customBold(size: 28)
    }
    
    static var customTitle2: Font {
        return customBold(size: 22)
    }
    
    static var customTitle3: Font {
        return customBold(size: 20)
    }
    
    static var customHeadline: Font {
        return customBold(size: 17)
    }
    
    static var customBody: Font {
        return customRegular(size: 17)
    }
    
    static var customCallout: Font {
        return customRegular(size: 16)
    }
    
    static var customSubheadline: Font {
        return customRegular(size: 15)
    }
    
    static var customFootnote: Font {
        return customRegular(size: 13)
    }
    
    static var customCaption: Font {
        return customRegular(size: 12)
    }
    
    static var customCaption2: Font {
        return customRegular(size: 11)
    }
}

