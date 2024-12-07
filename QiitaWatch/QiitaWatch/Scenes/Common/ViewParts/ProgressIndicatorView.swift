//
//  ProgressIndicatorView.swift
//  QiitaWatch
//
//  Created by 佐藤汰一 on 2024/11/15.
//

import UIKit

final class ProgressIndicatorView: UIView {
    
    override init(frame: CGRect = .zero) {
        
        super.init(frame: frame)
        setupIndicator()
    }
    
    required init?(coder: NSCoder) {
        
        super.init(coder: coder)
        setupIndicator()
    }
}

private extension ProgressIndicatorView {
    
    func setupIndicator() {
        
        self.backgroundColor = UIColor(resource: .progressIndicatorBackground)
        
        let activityView = UIActivityIndicatorView(style: .large)
        self.addSubview(activityView)
        
        // 制約の設定
        activityView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            activityView.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
        
        // ぐるぐる開始
        activityView.startAnimating()
    }
}
