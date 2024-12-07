//
//  ApiClient.swift
//  QiitaWatch
//
//  Created by 佐藤汰一 on 2024/11/14.
//

protocol ApiClient: Sendable {
    
    /// GETリクエストを送信する
    /// - Parameter service: リクエスト内容の構造体
    /// - Returns: GETリクエストで期待するレスポンスボディ
    func get<Output>(_ service: ApiService) async throws -> Output where Output: Decodable, Output: Sendable
}
