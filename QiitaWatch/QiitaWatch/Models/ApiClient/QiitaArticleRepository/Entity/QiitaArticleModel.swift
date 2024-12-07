//
//  QiitaArticleModel.swift
//  QiitaWatch
//
//  Created by 佐藤汰一 on 2024/11/16.
//

import Foundation

struct QiitaArticleModel: Decodable, Equatable, Identifiable {
    
    /// ID
    let id: String
    /// 記事のタイトル
    let title: String
    /// タグ
    let tags: [Tag]
    /// LGTM数
    let likesCount: Int
    /// 投稿日時
    let createdAt: Date
    /// 記事のURL
    let url: String
    
    init(id: String, title: String, tags: [Tag], likesCount: Int, createdAt: Date, url: String) {
        
        self.id = id
        self.title = title
        self.tags = tags
        self.likesCount = likesCount
        self.createdAt = createdAt
        self.url = url
    }
    
    init(from decoder: any Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.title = try container.decode(String.self, forKey: .title)
        self.tags = try container.decode([QiitaArticleModel.Tag].self, forKey: .tags)
        self.likesCount = try container.decode(Int.self, forKey: .likesCount)
        self.url = try container.decode(String.self, forKey: .url)
        
        // createdAtのdecode処理
        let dateString = try container.decode(String.self, forKey: .createdAt)
        guard let createdAt = DateFormatter.qiitaApiDatetimeFormat.date(from: dateString) else {
            
            throw DecodingError.dataCorruptedError(in: try container.nestedUnkeyedContainer(forKey: .createdAt), debugDescription: "Failed parse dateString(\(dateString)) to Date type.")
        }
        
        self.createdAt = createdAt
    }
    
    struct Tag: Decodable, Equatable {
        
        /// タグの名前
        let name: String
        /// タグのバージョンリスト
        let versions: [String]
    }
    
    enum CodingKeys: String, CodingKey {
        
        case id
        case title
        case tags
        case likesCount = "likes_count"
        case createdAt = "created_at"
        case url
    }
}


extension DateFormatter {
    
    static var qiitaApiDatetimeFormat: DateFormatter {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        return dateFormatter
    }
}
