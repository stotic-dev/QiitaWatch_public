//
//  AsyncImageViewTest.swift
//  QiitaWatchTests
//
//  Created by 佐藤汰一 on 2024/11/16.
//

import Alamofire
import XCTest

@testable import QiitaWatch

@MainActor
final class AsyncImageViewTest: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
}

extension AsyncImageViewTest {
    
    // MARK: - 正常系
    
    /// 画面表示時の処理を確認
    ///
    /// # 仕様
    /// - 受け取ったURLから画像を取得する
    func testOnAppearWithSafeUrl() async throws {
        
        let inputUrl = URL(string: "https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/xxxxxx/profile-images/xxxxx")!
        let originalImage = UIImage(systemName: "questionmark")!
        let expectedData = originalImage.pngData()!
        let expectedImage = UIImage(data: expectedData)!
        let mockImageRepository = MockCloudImageRepository(expectedUrl: inputUrl,
                                                           expectedResult: .success(expectedData))
        
        let testViewModel = AsyncImageViewModel(imageURL: inputUrl,
                                                cloudImageRepository: mockImageRepository)
        
        let expectation = XCTestExpectation(description: "testOnAppearWithSafeUrl")
        Task {
            
            await assertViewState(actualStateStream: testViewModel.stateObserver!,
                                  expectedStateStream: [
                                    .initial(state: .init(originalImage)),
                                    .loading,
                                    .appeared(state: .init(expectedImage))
                                  ],
                                  expectation: expectation)
        }
        
        await testViewModel.onAppear()
        
        await fulfillment(of: [expectation], timeout: 5)
    }
    
    // MARK: - 異常系
    
    /// 不正なURLにより画像取得に失敗したケースの確認
    ///
    /// # 仕様
    /// - 受け取ったURLがnilの場合デフォルトの画像を取得する
    func testFailedByNilUrl() async throws {
        
        let expectedImage = UIImage(systemName: "questionmark")!
        
        let testViewModel = AsyncImageViewModel(imageURL: nil)
        
        let expectation = XCTestExpectation(description: "testFailedByNilUrl")
        Task {
            
            await assertViewState(actualStateStream: testViewModel.stateObserver!,
                                  expectedStateStream: [
                                    .initial(state: .init(expectedImage)),
                                    .loading,
                                    .appeared(state: .init(expectedImage))
                                  ],
                                  expectation: expectation)
        }
        
        await testViewModel.onAppear()
        
        await fulfillment(of: [expectation], timeout: 5)
    }
    
    /// 管理外の副作用により画像取得に失敗したケースの確認
    ///
    /// # 仕様
    /// - クラウドからの画像の取得に失敗した場合、デフォルトの画像を取得する
    func testFailedDownloadImage() async throws {
        
        let inputUrl = URL(string: "https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/xxxxxx/profile-images/xxxxx")!
        let expectedImage = UIImage(systemName: "questionmark")!
        let mockImageRepository = MockCloudImageRepository(expectedUrl: inputUrl,
                                                           expectedResult: .failure(AFError.sessionDeinitialized))
        
        let testViewModel = AsyncImageViewModel(imageURL: inputUrl,
                                                cloudImageRepository: mockImageRepository)
        
        let expectation = XCTestExpectation(description: "testFailedDownloadImage")
        Task {
            
            await assertViewState(actualStateStream: testViewModel.stateObserver!,
                                  expectedStateStream: [
                                    .initial(state: .init(expectedImage)),
                                    .loading,
                                    .appeared(state: .init(expectedImage))
                                  ],
                                  expectation: expectation)
        }
        
        await testViewModel.onAppear()
        
        await fulfillment(of: [expectation], timeout: 5)
    }
}
