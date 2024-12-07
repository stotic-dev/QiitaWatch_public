//
//  QiitaUserDetailView.swift
//  QiitaWatch
//
//  Created by 佐藤汰一 on 2024/11/18.
//

import UIKit

@MainActor
protocol QiitaUserDetailViewDelegate: AnyObject {
    
    /// フォロー人数ボタンを押下時
    func tappedFolloweeButton()
    /// フォロワー人数ボタンを押下時
    func tappedFollowerButton()
}

final class QiitaUserDetailView: UIView {
    
    // MARK: - public property
    
    weak var delegate: QiitaUserDetailViewDelegate?
    
    // MARK: - private property
    
    // ユーザーアイコン
    private let iconImageView: UIImageView
    // ユーザーID
    private let userIdLabel = UILabel()
    // 紹介文表示用のラベル
    private let descriptionLabel = UILabel()
    // フォローボタン
    private let followeeButton = UIButton()
    // フォロワーボタン
    private let followerButton = UIButton()
    
    private let iconHeight: CGFloat = 80
    
    // MARK: - factory method
    
    static func getInstance(_ entity: UserDetailEntity) -> QiitaUserDetailView {
        
        return QiitaUserDetailView(entity)
    }
    
    // MARK: - initialize method
    
    private init(_ entity: UserDetailEntity, frame: CGRect = .zero) {
        
        self.iconImageView = AsyncImageView.getInstance(url: entity.iconImageUrl)
        super.init(frame: frame)
        
        setupLayoutView()
        setEntity(entity)
    }
    
    required init?(coder: NSCoder) {
        
        guard let iconImageView = coder.decodeObject(forKey: "iconImageView") as? UIImageView else { return nil }
        self.iconImageView = iconImageView
        super.init(coder: coder)
        
        setupLayoutView()
    }
}

// MARK: - private method

private extension QiitaUserDetailView {
    
    func setupLayoutView() {
        
        self.backgroundColor = .primaryBackgroundColor
        
        let headSectionStackView = UIStackView(arrangedSubviews: [iconImageView, userIdLabel])
        headSectionStackView.axis = .horizontal
        headSectionStackView.spacing = 16
        
        let tailSectionStackView = UIStackView(arrangedSubviews: [followeeButton, followerButton])
        tailSectionStackView.axis = .horizontal
        tailSectionStackView.spacing = 16
        tailSectionStackView.distribution = .fillEqually
        
        let containerStackView = UIStackView(arrangedSubviews: [
            headSectionStackView,
            descriptionLabel,
            tailSectionStackView
        ])
        containerStackView.axis = .vertical
        containerStackView.spacing = 8
        
        self.addSubview(containerStackView)
        containerStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerStackView.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
            containerStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            containerStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            containerStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8)
        ])
        
        iconImageView.contentMode = .scaleAspectFill
        iconImageView.clipsToBounds = true
        iconImageView.layer.cornerRadius = iconHeight / 2
        iconImageView.layer.borderWidth = 1
        iconImageView.layer.borderColor = UIColor.primaryTextColor.cgColor
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            iconImageView.widthAnchor.constraint(equalTo: iconImageView.heightAnchor),
            iconImageView.heightAnchor.constraint(equalToConstant: iconHeight)
        ])
        
        userIdLabel.font = .projectFont(.large)
        userIdLabel.textColor = .primaryTextColor
        
        descriptionLabel.font = .projectFont(.small)
        descriptionLabel.textColor = .primaryTextColor
        descriptionLabel.numberOfLines = .zero
        descriptionLabel.lineBreakMode = .byWordWrapping
        
        followeeButton.style()
        followeeButton.addTarget(self, action: #selector(tappedFolloweeButton), for: .touchUpInside)
        followerButton.style()
        followerButton.addTarget(self, action: #selector(tappedFollowerButton), for: .touchUpInside)
    }
    
    func setEntity(_ entity: UserDetailEntity) {
        
        userIdLabel.text = entity.userId
        descriptionLabel.text = entity.description
        followeeButton.setTitle("\(entity.followeeCount) フォロー", font: .medium)
        followerButton.setTitle("\(entity.followerCount) フォロワー", font: .medium)
    }
    
    @objc func tappedFolloweeButton() {
        
        delegate?.tappedFolloweeButton()
    }
    
    @objc func tappedFollowerButton() {
        
        delegate?.tappedFollowerButton()
    }
}

struct UserDetailEntity: Equatable {
    
    // ユーザーアイコン
    let iconImageUrl: URL?
    // ユーザーID
    let userId: String
    // 紹介文
    let description: String
    // フォローボタン
    let followeeCount: Int
    // フォロワーボタン
    let followerCount: Int
}
