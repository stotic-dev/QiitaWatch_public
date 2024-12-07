//
//  PaddingLabel.swift
//  QiitaWatch
//
//  Created by 佐藤汰一 on 2024/11/18.
//

import UIKit

/// Padding付きラベル
final class PaddingLabel: UILabel {

    var verticalPadding: PaddingType = .small
    var horizontalPadding: PaddingType = .medium
    
    override func drawText(in rect: CGRect) {
        
        let insets = UIEdgeInsets(top: verticalPadding.rawValue,
                                  left: horizontalPadding.rawValue,
                                  bottom: verticalPadding.rawValue,
                                  right: horizontalPadding.rawValue)
        super.drawText(in: rect.inset(by: insets))
    }
    
    override var intrinsicContentSize: CGSize {
        
        var intrinsicContentSize = super.intrinsicContentSize
        intrinsicContentSize.height += verticalPadding.rawValue * 2
        intrinsicContentSize.width += horizontalPadding.rawValue * 2
        return intrinsicContentSize
    }
}

extension PaddingLabel {
    
    enum PaddingType: CGFloat {
        
        case small = 4
        case medium = 8
        case large = 16
    }
}
