//
//  XCTestCase+Extension.swift
//  QiitaWatchTests
//
//  Created by 佐藤汰一 on 2024/11/17.
//

import XCTest

extension XCTestCase {
    
    /// テストバンドルのリソースをData型として取得
    /// - Parameter key: リソースのKey
    func getTestResourceData(_ key: TestResourceKey) -> Data? {
        let testBundle = Bundle(for: type(of: self))
        let path = testBundle.url(forResource: key.rawValue, withExtension: "json")
        let data = try? Data(contentsOf: path!, options: .uncached)
        return data
    }
    
    enum TestResourceKey: String {
        
        case qiitaUserApiResponseFoundCase = "qiita-user-response-found"
        case qiitaUserApiResponseNotFoundCase = "qiita-user-response-not-found"
        case qiitaArticleApiResponse = "qiita-items-response"
        case qiitaUserResponseFoundDescriptionNil = "qiita-user-response-found-description-nil"
    }
}
