//
//  XCTest+Extension.swift
//  QiitaWatchTests
//
//  Created by 佐藤汰一 on 2024/11/16.
//

import XCTest

extension XCTestCase {
    
    /// ViewStateの遷移と内容のアサーション
    /// - Parameters:
    ///   - actualStateStream: 実際のStateObserver
    ///   - expectedStateStream: 期待するStateの配列
    ///   - expectation: アサーション完了検知用のexpectation
    @MainActor
    func assertViewState<State>(actualStateStream stream: AsyncStream<State>,
                                expectedStateStream: [State],
                                expectation: XCTestExpectation) async where State: Equatable, State: Sendable {
        
        var actualStateStream: [State] = []
        for await state in stream { actualStateStream.append(state) }
        
        guard actualStateStream.count == expectedStateStream.count else {
            
            XCTFail("Missing view state.(actual: \(actualStateStream) expected: \(expectedStateStream))")
            expectation.fulfill()
            return
        }
        
        actualStateStream.indices.forEach {
            
            print("asserting actual: \(actualStateStream[$0]) expected: \(expectedStateStream[$0])")
            XCTAssertEqual(actualStateStream[$0], expectedStateStream[$0])
        }
        
        expectation.fulfill()
    }
}
