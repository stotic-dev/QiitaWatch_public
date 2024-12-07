//
//  UIImage+Extension.swift
//  QiitaWatch
//
//  Created by 佐藤汰一 on 2024/11/16.
//

import UIKit

extension UIImage {
    
    // テストでUIImageをインスタンスのアドレスに左右されず比較するための拡張
    static func ==(lhs: UIImage, rhs: UIImage) -> Bool {
        
        return lhs === rhs || lhs.pngData() == rhs.pngData()
    }
}
