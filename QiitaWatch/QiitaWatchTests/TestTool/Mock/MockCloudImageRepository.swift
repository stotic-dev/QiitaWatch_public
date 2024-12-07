//
//  MockCloudImageRepository.swift
//  QiitaWatchTests
//
//  Created by 佐藤汰一 on 2024/11/16.
//

import Foundation
import XCTest

@testable import QiitaWatch

struct MockCloudImageRepository: CloudImageRepository {
    
    private let expectedUrl: URL
    private let expectedResult: Result<Data?, Error>
    
    init(expectedUrl: URL, expectedResult: Result<Data?, Error>) {
        
        self.expectedUrl = expectedUrl
        self.expectedResult = expectedResult
    }
    
    func download(_ url: URL) async throws -> Data? {
        
        print("actual url: \(url), expected url: \(expectedUrl)")
        XCTAssertEqual(url, expectedUrl)
        
        return try expectedResult.get()
    }
}
