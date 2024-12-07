//
//  QiitaUserModel.swift
//  QiitaWatch
//
//  Created by 佐藤汰一 on 2024/11/14.
//

struct QiitaUserModel: Decodable, Equatable {
    
    /// ユーザーID
    let id: String
    /// 名前
    let name: String
    /// 説明文
    let description: String
    /// フォロー数
    let followeesCount: Int
    /// フォロワー数
    let followersCount: Int
    /// プロフィール画像
    let profile_image_url: String
    
    init(id: String,
         name: String,
         description: String,
         followeesCount: Int,
         followersCount: Int,
         profile_image_url: String) {
        
        self.id = id
        self.name = name
        self.description = description
        self.followeesCount = followeesCount
        self.followersCount = followersCount
        self.profile_image_url = profile_image_url
    }
    
    init(from decoder: any Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.followeesCount = try container.decode(Int.self, forKey: .followeesCount)
        self.followersCount = try container.decode(Int.self, forKey: .followersCount)
        self.profile_image_url = try container.decode(String.self, forKey: .profile_image_url)
        
        self.description = (try? container.decode(String.self, forKey: .description)) ?? "-"
    }
    
    enum CodingKeys: String, CodingKey {
        
        case id
        case name
        case description
        case followeesCount = "followees_count"
        case followersCount = "followers_count"
        case profile_image_url
    }
}
