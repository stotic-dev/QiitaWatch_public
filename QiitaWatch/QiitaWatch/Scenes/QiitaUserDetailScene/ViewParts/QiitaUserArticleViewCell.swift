//
//  QiitaUserArticleViewCell.swift
//  QiitaWatch
//
//  Created by 佐藤汰一 on 2024/11/18.
//

import UIKit

final class QiitaUserArticleViewCell: UITableViewCell {
    
    // MARK: id definition
    
    static let identifire = "QiitaUserArticleViewCell"
    override var reuseIdentifier: String? { return Self.identifire }
    
    // MARK: - private property
    
    private let titleLabel = UILabel()
    private let tagLabel = UILabel()
    private let tagListScrollView = UIScrollView()
    private let lgtmLabel = UILabel()
    private let createdAtLabel = UILabel()
    private var tagCupselLabels: [UILabel] = []
    private var tagListStackViewWidthConstraint: NSLayoutConstraint?
    
    // MARK: - lifecycle method

    override func awakeFromNib() {
        
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        
        super.setSelected(selected, animated: animated)
    }
    
    override func layoutSubviews() {
        
        updateTagListStackViewWidth()
    }
    
    // MARK: - initialize method
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayoutComponent()
    }
    
    required init?(coder: NSCoder) {
        
        super.init(coder: coder)
        setupLayoutComponent()
    }
    
    // MARK: - public method
    
    func setupCell(with article: QiitaArticleModel) {
        
        // タイトルの設定
        titleLabel.text = article.title
        
        // タグセクションの設定
        tagListScrollView.subviews.forEach { $0.removeFromSuperview() }
        tagLabel.text = "タグ"
        
        tagCupselLabels = createTagCupselLabels(article.tags.map { $0.name })
        let tagListStackView = UIStackView(arrangedSubviews: tagCupselLabels)
        tagListStackView.axis = .horizontal
        tagListStackView.spacing = 4
        
        tagListScrollView.addSubview(tagListStackView)
        tagListStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tagListStackView.topAnchor.constraint(equalTo: tagListScrollView.topAnchor),
            tagListStackView.leadingAnchor.constraint(equalTo: tagListScrollView.leadingAnchor),
            tagListStackView.heightAnchor.constraint(equalTo: tagListScrollView.heightAnchor),
        ])
        tagListStackViewWidthConstraint = tagListStackView.widthAnchor.constraint(equalToConstant: intrinsicContentSize.width)
        
        // LGTMの設定
        lgtmLabel.text = "LGTM \(article.likesCount)"
        
        // 作成日時の設定
        createdAtLabel.text = DateFormatter.defaultFormat.string(from: article.createdAt)
    }
}

// MARK: - private method

private extension QiitaUserArticleViewCell {
    
    func setupLayoutComponent() {
        
        // セルの背景色
        contentView.backgroundColor = .secondaryBackgroundColor
        
        // タグセクションのContainer設定
        let tagSectionStackView = UIStackView(arrangedSubviews: [tagLabel, tagListScrollView])
        tagSectionStackView.axis = .horizontal
        tagSectionStackView.spacing = 10
        
        // フッターセクションのContainer設定
        let footerStackView = UIStackView(arrangedSubviews: [lgtmLabel, createdAtLabel])
        footerStackView.axis = .horizontal
        footerStackView.distribution = .fillEqually
        footerStackView.spacing = .zero
        
        let separatorView = UIView()
        separatorView.backgroundColor = .primaryTextColor
        
        // セルコンテンツのContainer設定
        let containerStackView = UIStackView(arrangedSubviews: [titleLabel, tagSectionStackView, footerStackView, separatorView])
        containerStackView.axis = .vertical
        containerStackView.spacing = 8
        
        contentView.addSubview(containerStackView)
        
        containerStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
        
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        // タイトルラベルの設定
        titleLabel.font = .projectFont(.medium)
        titleLabel.textColor = .primaryTextColor
        titleLabel.textAlignment = .left
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byWordWrapping
        
        // タグタイトルラベルの設定
        tagLabel.font = .projectFont(.medium)
        tagLabel.textColor = .primaryTextColor
        tagLabel.translatesAutoresizingMaskIntoConstraints = false
        tagLabel.widthAnchor.constraint(equalToConstant: 35).isActive = true
        
        // LGTMラベルの設定
        lgtmLabel.font = .projectFont(.medium)
        lgtmLabel.textColor = .primaryTextColor
        lgtmLabel.textAlignment = .left
        
        // 作成日時ラベルの設定
        createdAtLabel.font = .projectFont(.small)
        createdAtLabel.textColor = .primaryTextColor
        createdAtLabel.textAlignment = .right
    }
    
    func createTagCupselLabels(_ tags: [String]) -> [UILabel] {
        
        tags.map {
            
            let tagCupselLabel = PaddingLabel()
            tagCupselLabel.text = $0
            tagCupselLabel.font = .projectFont(.small)
            tagCupselLabel.textColor = UIColor(resource: .primaryFillStyleForeground)
            tagCupselLabel.backgroundColor = UIColor(resource: .primaryFillStyleBackground)
            tagCupselLabel.layer.cornerRadius = 4
            tagCupselLabel.clipsToBounds = true
            tagCupselLabel.textAlignment = .center
            tagCupselLabel.horizontalPadding = .large
            return tagCupselLabel
        }
    }
    
    func updateTagListStackViewWidth() {
        
        let labelsWidth = tagCupselLabels.reduce(into: CGFloat.zero) { $0 += $1.intrinsicContentSize.width }
        tagListStackViewWidthConstraint?.constant = labelsWidth + CGFloat((tagCupselLabels.count - 1) * 4)
        updateConstraintsIfNeeded()
        tagListScrollView.contentSize.width = tagListStackViewWidthConstraint?.constant ?? .zero
        
        tagListStackViewWidthConstraint?.isActive = tagListStackViewWidthConstraint?.constant ?? .zero > .zero
    }
}

extension DateFormatter {
    
    static var defaultFormat: DateFormatter {
        
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.timeZone = TimeZone.current
        formatter.locale = Locale.current
        return formatter
    }
}
