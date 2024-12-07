//
//  CommonButton.swift
//  QiitaWatch
//
//  Created by 佐藤汰一 on 2024/11/15.
//

import UIKit

extension UIButton {
    
    /// スタイルを適用する
    /// - Parameters:
    ///   - foregroundColor: テキスト、画像、縁の色
    ///   - backgroundColor: 背景色
    ///   - pressedBackgroundColor: タップ時の色
    ///   - cornerRadius: 角丸の値
    ///   - strokeWidth: 縁の長さ
    @discardableResult
    func style(foregroundColor: UIColor = UIColor(resource: .primaryButtonForeground),
               backgroundColor: UIColor = UIColor(resource: .primaryButtonBackground),
               pressedBackgroundColor: UIColor = UIColor(resource: .primaryPressedButtonBackground),
               cornerRadius: CGFloat = 8,
               strokeWidth: CGFloat = .zero) -> UIButton {
        
        var config = self.configuration ?? .plain()
        config.baseForegroundColor = foregroundColor
        config.background.backgroundColor = backgroundColor
        config.background.strokeColor = foregroundColor
        config.background.cornerRadius = cornerRadius
        config.background.strokeWidth = strokeWidth
        self.configuration = config
        self.updateConfiguration()
        
        self.configurationUpdateHandler = { [weak self] in
            
            guard let self else { return }
            
            switch $0.state {
                
            case .focused, .disabled, .selected, .highlighted:
                self.updateBackground(background: pressedBackgroundColor)
                
            default:
                self.updateBackground(background: backgroundColor)
            }
        }
        
        return self
    }
    
    @discardableResult
    func setTitle(_ title: String, font: CommonFontSize = .medium) -> UIButton {
        
        var config = self.configuration
        let titleContainer = AttributeContainer([.font: UIFont.projectFont(font)])
        config?.attributedTitle = AttributedString(title, attributes: titleContainer)
        self.configuration = config
        self.updateConfiguration()
        
        return self
    }
}

private extension UIButton {
    
    func updateBackground(background: UIColor) {
        
        var config = self.configuration ?? .plain()
        config.background.backgroundColor = background
        self.configuration = config
        self.updateConfiguration()
    }
}
