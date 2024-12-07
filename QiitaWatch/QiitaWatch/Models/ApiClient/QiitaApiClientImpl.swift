//
//  QiitaApiClientImpl.swift
//  QiitaWatch
//
//  Created by 佐藤汰一 on 2024/11/15.
//

import Alamofire
import Foundation

struct QiitaApiClientImpl: ApiClient {
    
    private let timeout: TimeInterval = 5
    
    func get<Output>(_ service: ApiService) async throws -> Output where Output : Decodable, Output: Sendable {
        
        log.info("service: \(service)")
        
        
        return try await withCheckedThrowingContinuation { continuation in
            
            AF.request(service.baseUrl,
                       method: .get,
                       parameters: service.parameters,
                       requestModifier: {
                $0.timeoutInterval = timeout
                $0.cachePolicy = .reloadRevalidatingCacheData
            })
            .responseDecodable(of: Output.self) { response in
                
                log.debug("response: \(response.debugDescription)")
                
                switch response.result {
                    
                case .success(let data):
                    continuation.resume(returning: data)
                    
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
            .resume()
        }
    }
}
