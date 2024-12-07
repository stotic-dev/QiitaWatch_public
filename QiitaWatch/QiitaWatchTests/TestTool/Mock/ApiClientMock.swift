//
//  ApiClientMock.swift
//  QiitaWatchTests
//
//  Created by 佐藤汰一 on 2024/11/14.
//

import Alamofire
import XCTest

@testable import QiitaWatch

final class ApiClientMock<ExpectedOutput>: @unchecked Sendable, ApiClient where ExpectedOutput: Decodable, ExpectedOutput: Sendable {
    
    private let expectedInputs: [ApiService]
    private let expectedResults: [Result<ExpectedOutput, Error>]
    private var callCount = 0
    
    init(expectedInput: [ApiService], expectedResult: [Result<ExpectedOutput, Error>]) {
        
        self.expectedInputs = expectedInput
        self.expectedResults = expectedResult
    }
    
    func get<Output>(_ service: QiitaWatch.ApiService) async throws -> Output where Output : Decodable, Output : Sendable {
        
        XCTAssertEqual(service, expectedInputs[callCount])
        let result = try expectedResults[callCount].get() as! Output
        
        callCount += 1
        return result
    }
}
