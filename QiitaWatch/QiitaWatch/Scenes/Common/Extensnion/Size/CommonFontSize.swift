//
//  CommonFontSize.swift
//  QiitaWatch
//
//  Created by 佐藤汰一 on 2024/11/15.
//

import UIKit

enum CommonFontSize {
    
    case small
    case medium
    case large
    
    var get: UIFont {
        
        switch self {
            
        case .small: return .systemFont(ofSize: 14)
        case .medium: return .systemFont(ofSize: 18)
        case .large: return .systemFont(ofSize: 22, weight: .bold)
        }
    }
}

extension UIFont {
    
    static func projectFont(_ font: CommonFontSize) -> UIFont {
        
        return font.get
    }
}
