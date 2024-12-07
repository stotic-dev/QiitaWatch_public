//
//  QiitaUserModelTest.swift
//  QiitaWatchTests
//
//  Created by 佐藤汰一 on 2024/11/17.
//

import XCTest

@testable import QiitaWatch

final class QiitaUserModelTest: XCTestCase {
    
    let decoder = JSONDecoder()
    
    // MARK: - 正常系
    
    func testFoundUserResponse() throws {
        
        guard let data = getTestResourceData(.qiitaUserApiResponseFoundCase) else {
            
            XCTFail("Not found target resouce.")
            return
        }
        
        let decodedObject = try decoder.decode(QiitaUserModel.self, from: data)
        
        XCTAssertEqual(decodedObject,
                       QiitaUserModel(id: "stotic-dev",
                                      name: "",
                                      description: "カメ好き！",
                                      followeesCount: 6,
                                      followersCount: 0,
                                      profile_image_url: "https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/3359094/profile-images/1727252399"))
    }
    
    func testFoundUserDescriptionNilResponse() throws {
        
        guard let data = getTestResourceData(.qiitaUserResponseFoundDescriptionNil) else {
            
            XCTFail("Not found target resouce.")
            return
        }
        
        let decodedObject = try decoder.decode(QiitaUserModel.self, from: data)
        
        XCTAssertEqual(decodedObject,
                       QiitaUserModel(id: "stotic-dev",
                                      name: "",
                                      description: "-",
                                      followeesCount: 6,
                                      followersCount: 0,
                                      profile_image_url: "https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/3359094/profile-images/1727252399"))
    }
    
    func testNotFoundUserResponse() throws {
        
        guard let data = getTestResourceData(.qiitaUserApiResponseNotFoundCase) else {
            
            XCTFail("Not found target resouce.")
            return
        }
        
        XCTAssertThrowsError(try decoder.decode(QiitaUserModel.self, from: data))
    }
}
