//
//  QiitaArticleRepository.swift
//  QiitaWatch
//
//  Created by 佐藤汰一 on 2024/11/16.
//

import Foundation

struct QiitaArticleRepository {
    
    private let client: ApiClient
    
    init(client: ApiClient) {
        
        self.client = client
    }
    
    func fetchArticlesByUserId(userId: String, page: Int) async throws(QiitaApiRepositoryError) -> [QiitaArticleModel] {
        
        do {
            
            return try await client.get(.fetchArticlesByUserId(userId: userId, page: page))
        }
        catch {
            
            if let error = error as? QiitaApiRepositoryError { throw error }
            throw .clientError(reason: "Failed to fetch articles by userId: \(userId), error :\(error)",
                               originalError: error)
        }
    }
}

// MARK: - service definition

extension ApiService {
    
    /// ユーザーの投稿記事取得APIのURL
    private static let fetchArticlesByUserIdApiUrl = "https://qiita.com/api/v2/users/%@/items"
    
    static func fetchArticlesByUserId(userId: String, page: Int) throws(QiitaApiRepositoryError) -> Self {
        
        let stringUrl = String(format: Self.fetchArticlesByUserIdApiUrl, userId)
        guard let url = URL(string: stringUrl,
                            encodingInvalidCharacters: false) else {
            
            throw .failedCreateUrlError(url: stringUrl)
        }
        return ApiService(url: url,
                          parameters: QiitaCommonUrlParamBuilder.build(page: page))
    }
}
