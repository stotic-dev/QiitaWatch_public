//
//  QiitaUserRepository.swift
//  QiitaWatch
//
//  Created by 佐藤汰一 on 2024/11/14.
//

import Alamofire
import Foundation

struct QiitaUserRepository: Sendable {
    
    private let client: ApiClient
    
    init(client: ApiClient) {
        
        self.client = client
    }
    
    func fetchByUserId(_ userId: String) async throws(QiitaApiRepositoryError) -> QiitaUserModel {
                
        do {
            
            return try await client.get(.fetchQiitaUsersService(keyword: userId))
        }
        catch(let error as AFError) {
            
            if error.isResponseSerializationError {
                
                throw .noHitUserError
            }
            
            throw .clientError(reason: "Failed to fetch user by id: \(userId), error: \(error).",
                               originalError: error)
        }
        catch {
            
            throw .clientError(reason: "Failed to fetch user by id: \(userId), error: \(error).",
                               originalError: error)
        }
    }
    
    func fetchFolloweeUsersByUserId(_ userId: String, page: Int) async throws(QiitaApiRepositoryError) -> [QiitaUserModel] {
        
        do {
            
            return try await client.get(.fetchQiitaFolloweeUsersService(userId: userId, page: page))
        }
        catch {
            
            if let error = error as? QiitaApiRepositoryError { throw error }
            throw .clientError(reason: "Failed to fetch followee users by id: \(userId), error: \(error).",
                               originalError: error)
        }
    }
    
    func fetchFollowerUsersByUserId(_ userId: String, page: Int) async throws(QiitaApiRepositoryError) -> [QiitaUserModel] {
        
        do {
            
            return try await client.get(.fetchQiitaFollowerUsersService(userId: userId, page: page))
        }
        catch {
            
            if let error = error as? QiitaApiRepositoryError { throw error }
            throw .clientError(reason: "Failed to fetch followee users by id: \(userId), error: \(error).",
                               originalError: error)
        }
    }
}

// MARK: - service definition

extension ApiService {
    
    /// フォローユーザー取得APIのベースURL
    private static let followeeUsersBaseUrlFormat = "https://qiita.com/api/v2/users/%@/followees"
    /// フォロワーユーザー取得APIのベースURL
    private static let followerUsersBaseUrlFormat = "https://qiita.com/api/v2/users/%@/followers"
    
    static func fetchQiitaUsersService(keyword: String) -> Self {
        
        guard let url = URL(string: "https://qiita.com/api/v2/users/")?.appending(path: keyword) else {
            
            // URLが生成できないケースは、固定値のURL自体に誤りがあるケースで外部の入力に依存せず定数の誤りなのでfatalエラーに倒す
            fatalError("Invalid URL.")
        }
        
        return ApiService(url: url)
    }
    
    static func fetchQiitaFolloweeUsersService(userId: String, page: Int) throws(QiitaApiRepositoryError) -> Self {
        
        let stringUrl = String(format: followeeUsersBaseUrlFormat, userId)
        guard let url = URL(string: stringUrl,
                            encodingInvalidCharacters: false) else {
            
            throw .failedCreateUrlError(url: stringUrl)
        }
        
        return ApiService(url: url,
                          parameters: QiitaCommonUrlParamBuilder.build(page: page))
    }
    
    static func fetchQiitaFollowerUsersService(userId: String, page: Int) throws(QiitaApiRepositoryError) -> Self {
        
        let stringUrl = String(format: followerUsersBaseUrlFormat, userId)
        guard let url = URL(string: stringUrl,
                            encodingInvalidCharacters: false) else {
            
            throw .failedCreateUrlError(url: stringUrl)
        }
        
        return ApiService(url: url,
                          parameters: QiitaCommonUrlParamBuilder.build(page: page))
    }
}
