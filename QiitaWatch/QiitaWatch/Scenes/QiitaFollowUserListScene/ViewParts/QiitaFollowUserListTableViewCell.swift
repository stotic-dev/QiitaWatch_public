//
//  QiitaFollowUserListTableViewCell.swift
//  QiitaWatch
//
//  Created by 佐藤汰一 on 2024/11/20.
//

import UIKit

final class QiitaFollowUserListTableViewCell: UITableViewCell {
    
    // MARK: - id definition
    
    static let identifire = "QiitaFollowUserListTableViewCell"
    override var reuseIdentifier: String? { return Self.identifire }
    
    // MARK: - private property
    
    // MARK: ui component
    
    private let containerStackView = UIStackView()
    private let userNameLabel = UILabel()
    private let followeeCountLabel = UILabel()
    private let followerCountLabel = UILabel()
    
    // MARK: constant
    
    private let iconImageWidth: CGFloat = 70
    
    // MARK: - initialize method
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        
        super.init(coder: coder)
        setupLayout()
    }
    
    // MARK: - lifecycle method

    override func awakeFromNib() {
        
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        
        super.setSelected(selected, animated: animated)
    }

    // MARK: - public method
    
    func setUserEntity(_ entity: QiitaFollowUserListViewModel.UserEntity) {
        
        userNameLabel.text = entity.userId
        followeeCountLabel.text = "\(entity.followeeCount) フォロー"
        followerCountLabel.text = "\(entity.followerCount) フォロワー"
        setUserIcon(iconURL: entity.userIconImageUrl)
    }
}

// MARK: - private method

private extension QiitaFollowUserListTableViewCell {
    
    func setupLayout() {
        
        self.selectionStyle = .none
        
        let followCountStackView = UIStackView(arrangedSubviews: [followeeCountLabel, followerCountLabel])
        followCountStackView.axis = .horizontal
        followCountStackView.spacing = 10
        followCountStackView.distribution = .fillEqually
        
        let rightContentsStackView = UIStackView(arrangedSubviews: [userNameLabel, followCountStackView])
        rightContentsStackView.axis = .vertical
        rightContentsStackView.spacing = 8
        
        containerStackView.axis = .horizontal
        containerStackView.spacing = 10
        containerStackView.alignment = .center
        containerStackView.addArrangedSubview(rightContentsStackView)
        
        contentView.addSubview(containerStackView)
        containerStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
        
        rightContentsStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            rightContentsStackView.topAnchor.constraint(equalTo: containerStackView.topAnchor),
            rightContentsStackView.bottomAnchor.constraint(equalTo: containerStackView.bottomAnchor),
        ])
        
        userNameLabel.font = .projectFont(.large)
        userNameLabel.textColor = .primaryTextColor
        userNameLabel.numberOfLines = 1
        
        followeeCountLabel.font = .projectFont(.medium)
        followeeCountLabel.textColor = .primaryTextColor
        
        followerCountLabel.font = .projectFont(.medium)
        followerCountLabel.textColor = .primaryTextColor
    }
    
    func setUserIcon(iconURL: URL?) {
        
        // 前回設定していた画像があれば削除
        if let prevImageView = containerStackView.arrangedSubviews.first(where: { $0 is AsyncImageView }) {
            containerStackView.removeArrangedSubview(prevImageView)
            prevImageView.removeFromSuperview()
        }
        
        let iconImageView = AsyncImageView.getInstance(url: iconURL)
        iconImageView.contentMode = .scaleAspectFill
        iconImageView.clipsToBounds = true
        iconImageView.layer.cornerRadius = iconImageWidth / 2
        iconImageView.layer.borderWidth = 1
        iconImageView.layer.borderColor = UIColor.primaryTextColor.cgColor
        
        containerStackView.insertArrangedSubview(iconImageView, at: .zero)
        
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            iconImageView.widthAnchor.constraint(equalToConstant: iconImageWidth),
            iconImageView.heightAnchor.constraint(equalTo: iconImageView.widthAnchor),
        ])
    }
}
