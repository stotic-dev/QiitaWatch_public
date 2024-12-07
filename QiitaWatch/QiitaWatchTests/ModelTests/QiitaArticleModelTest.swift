//
//  QiitaArticleModelTest.swift
//  QiitaWatchTests
//
//  Created by 佐藤汰一 on 2024/11/17.
//

import XCTest

@testable import QiitaWatch

final class QiitaArticleModelTest: XCTestCase {
    
    let decoder = JSONDecoder()
    
    // MARK: - 正常系
    
    func testArticleModelResponse() throws {
        
        guard let data = getTestResourceData(.qiitaArticleApiResponse) else {
            
            XCTFail("Not found target resouce.")
            return
        }
        
        let expectedObject = [
            QiitaArticleModel(id: "01e1b20a1417998994ab",
                              title: "SwiftUIでさらに表示するのUIを作る",
                              tags: [
                                 .init(name: "iOS", versions: []),
                                 .init(name: "Swift", versions: []),
                                 .init(name: "SwiftUI", versions: [])
                              ],
                               likesCount: 2,
                               createdAt: convertStringToDate("2024-11-10T11:43:21+09:00")!,
                              url: "https://qiita.com/stotic-dev/items/01e1b20a1417998994ab"),
            QiitaArticleModel(id: "bb719b19707747b15feb",
                              title: "classがSendableに適合するためにはfinalなclassである必要がある件",
                              tags: [
                                 .init(name: "iOS", versions: []),
                                 .init(name: "Swift", versions: []),
                              ],
                               likesCount: 1,
                               createdAt: convertStringToDate("2024-11-09T00:59:56+09:00")!,
                              url: "https://qiita.com/stotic-dev/items/bb719b19707747b15feb")
        ]
        let decodedObject = try decoder.decode([QiitaArticleModel].self, from: data)
        XCTAssertEqual(decodedObject, expectedObject)
    }
}

private extension QiitaArticleModelTest {
    
    func convertStringToDate(_ string: String) -> Date? {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        return dateFormatter.date(from: string)
    }
}
