//
//  CloudImageRepositoryImpl.swift
//  QiitaWatch
//
//  Created by 佐藤汰一 on 2024/11/16.
//

import Alamofire
import Foundation

struct CloudImageRepositoryImpl: CloudImageRepository {
    
    // MARK: - private property
    
    private let timeout: TimeInterval = 5
    private let downloadQueue = DispatchQueue(label: "CloudImageRepositoryImpl")
    
    // MARK: public method
    
    func download(_ url: URL) async throws -> Data? {
        
        try await withCheckedThrowingContinuation { continuation in
            
            //            AF.download(url,
            //                        requestModifier: {
            //
            //                $0.timeoutInterval = timeout
            //                $0.cachePolicy = .reloadRevalidatingCacheData
            //            })
            AF.request(url,
                       requestModifier: {
                $0.timeoutInterval = timeout
                $0.cachePolicy = .reloadRevalidatingCacheData
            })
            .response(queue: downloadQueue) { response in
                
                log.debug("Received response: \(response.debugDescription)")
                
                if let error = response.error {
                    
                    continuation.resume(throwing: error)
                    return
                }
                
                continuation.resume(returning: response.data)
            }
        }
    }
}
