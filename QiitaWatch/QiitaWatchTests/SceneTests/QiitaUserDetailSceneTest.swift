//
//  QiitaUserDetailSceneTest.swift
//  QiitaWatchTests
//
//  Created by 佐藤汰一 on 2024/11/16.
//

import Alamofire
import XCTest

@testable import QiitaWatch

@MainActor
final class QiitaUserDetailSceneTest: XCTestCase {
    
    // MARK: - constant
    
    private let normalTestUser = QiitaUserModel(id: UUID().uuidString,
                                                name: "test name",
                                                description: "xxxxxxxx",
                                                followeesCount: 10,
                                                followersCount: 100,
                                                profile_image_url: "https://test.com/test.png")
    
    private let newestArticle = QiitaArticleModel(id: UUID().uuidString,
                                                  title: "article title1",
                                                  tags: [.init(name: "test1", versions: ["0.0.1"])],
                                                  likesCount: 2,
                                                  createdAt: Date(timeIntervalSince1970: 10000),
                                                  url: "https://qiita.com/stotic-dev/items/01e1b20a1417998994ab")
    
    private let oldestArticle = QiitaArticleModel(id: UUID().uuidString,
                                                  title: "article title2",
                                                  tags: [.init(name: "test2", versions: ["0.0.2"])],
                                                  likesCount: 8,
                                                  createdAt: Date(timeIntervalSince1970: 1000),
                                                  url: "ttps://qiita.com/stotic-dev/items/042fe9c2600e5b6283c4")
    // MARK: - 正常系
    
    /// 画面表示時の処理を確認
    ///
    /// # 仕様
    /// - 初期表示で、ユーザー情報を表示する
    /// - 画面表示時にユーザー情報から投稿記事を取得して表示する
    /// - 投稿記事取得中はぐるぐるを表示する
    /// - 投稿記事のセルをタップすると、記事画面に遷移する
    func testOnAppearWithSuccess() async throws {
        
        let expectedFetchingArticles: [QiitaArticleModel] = [
            oldestArticle,
            newestArticle
        ]
        let mockApiClient = try ApiClientMock(expectedInput: [.fetchArticlesByUserId(userId: normalTestUser.id, page: 1)],
                                          expectedResult: [.success(expectedFetchingArticles)])
        let testViewModel = QiitaUserDetailViewModel(userModel: normalTestUser, apiClient: mockApiClient)
        let expectation = expectation(description: "testOnAppearWithSuccess")
        
        await testViewModel.onAppear()
        
        guard let stateObserver = testViewModel.stateObserver else {
            
            XCTFail()
            return
        }
        
        Task {
            
            await assertViewState(actualStateStream: stateObserver,
                                  expectedStateStream: [
                                    .initial(state: .init(user: normalTestUser)), // 初期状態
                                    .loading(type: .initial), // ロード中
                                    .appeared(state: .init(user: normalTestUser,
                                                           articleList: expectedFetchingArticles.reversed())), // 記事取得完了
                                    .screenTransition(destination: .article(URL(string: newestArticle.url)!)) // 記事画面へ遷移
                                  ],
                                  expectation: expectation)
        }
        
        testViewModel.tappedArticleCell(newestArticle.id)
        testViewModel.onDisappear()
        
        await fulfillment(of: [expectation], timeout: 5)
    }
    
    /// フォロワーボタンタップを確認
    ///
    /// # 仕様
    /// - フォロワーボタンタップでフォロワー一覧画面へ遷移する
    func testTappedFollowerButton() async throws {
        
        let expectedFetchingArticles: [QiitaArticleModel] = []
        let mockApiClient = try ApiClientMock(expectedInput: [.fetchArticlesByUserId(userId: normalTestUser.id, page: 1)],
                                          expectedResult: [.success(expectedFetchingArticles)])
        let testViewModel = QiitaUserDetailViewModel(userModel: normalTestUser, apiClient: mockApiClient)
        let expectation = expectation(description: "testTappedFollowerButton")
        
        await testViewModel.onAppear()
        
        guard let stateObserver = testViewModel.stateObserver else {
            
            XCTFail()
            return
        }
        
        Task {
            
            await assertViewState(actualStateStream: stateObserver,
                                  expectedStateStream: [
                                    .initial(state: .init(user: normalTestUser)), // 初期状態
                                    .loading(type: .initial), // ロード中
                                    .appeared(state: .init(user: normalTestUser,
                                                           articleList: expectedFetchingArticles)), // 記事取得完了
                                    .screenTransition(destination: .follwer(normalTestUser.id)) // フォロワー一覧画面へ遷移
                                  ],
                                  expectation: expectation)
        }
        
        testViewModel.tappedFollowerButton()
        testViewModel.onDisappear()
        
        await fulfillment(of: [expectation], timeout: 5)
    }
    
    /// フォローボタンタップを確認
    ///
    /// # 仕様
    /// - フォローボタンタップでフォロー一覧画面へ遷移する
    func testTappedFolloweeButton() async throws {
        
        let expectedFetchingArticles: [QiitaArticleModel] = []
        let mockApiClient = try ApiClientMock(expectedInput: [.fetchArticlesByUserId(userId: normalTestUser.id, page: 1)],
                                          expectedResult: [.success(expectedFetchingArticles)])
        let testViewModel = QiitaUserDetailViewModel(userModel: normalTestUser, apiClient: mockApiClient)
        let expectation = expectation(description: "testTappedFolloweeButton")
        
        await testViewModel.onAppear()
        
        guard let stateObserver = testViewModel.stateObserver else {
            
            XCTFail()
            return
        }
        
        Task {
            
            await assertViewState(actualStateStream: stateObserver,
                                  expectedStateStream: [
                                    .initial(state: .init(user: normalTestUser)), // 初期状態
                                    .loading(type: .initial), // ロード中
                                    .appeared(state: .init(user: normalTestUser,
                                                           articleList: expectedFetchingArticles)), // 記事取得完了
                                    .screenTransition(destination: .followee(normalTestUser.id)) // フォロー一覧画面へ遷移
                                  ],
                                  expectation: expectation)
        }
        
        testViewModel.tappedFolloweeButton()
        testViewModel.onDisappear()
        
        await fulfillment(of: [expectation], timeout: 5)
    }
    
    /// 記事リストのスワイプの動作を確認
    ///
    /// # 仕様
    /// - 記事リストを上から下へスワイプすると最新の記事を取得する
    /// - 記事リストを下から上へスワイプすると、次ページの記事を取得する
    func testSwipeArticleList() async throws {
        
        let expectedFirstFetchingArticles: [QiitaArticleModel] = [newestArticle, oldestArticle]
        let expectedPushToRefreshFetchingArticle = [
            QiitaArticleModel(id: UUID().uuidString,
                              title: "PushToRefreshFetchingArticle",
                              tags: [.init(name: "PushToRefresh", versions: [])],
                              likesCount: 0,
                              createdAt: Date(timeIntervalSince1970: 0),
                              url: "https://qiita.com/stotic-dev/items/0000000")
        ]
        let expectedPullToRefreshFetchingArticle = [
            QiitaArticleModel(id: UUID().uuidString,
                              title: "PullToRefreshFetchingArticle",
                              tags: [.init(name: "PullToRefresh", versions: [])],
                              likesCount: 9,
                              createdAt: Date(timeIntervalSince1970: 20000),
                              url: "https://qiita.com/stotic-dev/items/111111"),
            newestArticle,
            oldestArticle
        ]
        let mockApiClient = try ApiClientMock(expectedInput: [
            .fetchArticlesByUserId(userId: normalTestUser.id, page: 1),
            .fetchArticlesByUserId(userId: normalTestUser.id, page: 2),
            .fetchArticlesByUserId(userId: normalTestUser.id, page: 1)
        ],
                                          expectedResult: [
                                            .success(expectedFirstFetchingArticles),
                                            .success(expectedPushToRefreshFetchingArticle),
                                            .success(expectedPullToRefreshFetchingArticle)
                                          ])
        let testViewModel = QiitaUserDetailViewModel(userModel: normalTestUser, apiClient: mockApiClient)
        let expectation = expectation(description: "testSwipeArticleList")
        
        await testViewModel.onAppear()
        
        guard let stateObserver = testViewModel.stateObserver else {
            
            XCTFail()
            return
        }
        
        Task {
            
            await assertViewState(actualStateStream: stateObserver,
                                  expectedStateStream: [
                                    .initial(state: .init(user: normalTestUser)), // 初期状態
                                    .loading(type: .initial), // ロード中
                                    .appeared(state: .init(user: normalTestUser,
                                                           articleList: expectedFirstFetchingArticles)), // 記事取得完了
                                    .loading(type: .nextPageArticlesFetching), // ロード中
                                    .appeared(state: .init(user: normalTestUser,
                                                           articleList: expectedFirstFetchingArticles + expectedPushToRefreshFetchingArticle)), // 記事取得完了
                                    .loading(type: .newArticlesFetching), // ロード中
                                    .appeared(state: .init(user: normalTestUser,
                                                           articleList: expectedPullToRefreshFetchingArticle + expectedPushToRefreshFetchingArticle)), // 記事取得完了
                                  ],
                                  expectation: expectation)
        }
        
        await testViewModel.pushToRefresh()
        await testViewModel.pullToRefresh()
        testViewModel.onDisappear()
        
        await fulfillment(of: [expectation], timeout: 5)
    }
    
    // MARK: - 異常系
    
    /// 記事取得で通信エラーが発生したケースを確認
    ///
    /// # 仕様
    /// - 通信エラーが発生した場合は、アラートを表示する
    /// - アラートのリトライボタンを押下すると、再度取得処理を行う
    /// - アラートの閉じるボタンを押下すると、アラートを閉じる
    func testFailedFetchArticlesWithNetwork() async throws {
        
        let mockApiClient = try ApiClientMock<[QiitaArticleModel]>(expectedInput: [.fetchArticlesByUserId(userId: normalTestUser.id, page: 1)],
                                          expectedResult: [.failure(AFError.explicitlyCancelled)])
        let testViewModel = QiitaUserDetailViewModel(userModel: normalTestUser, apiClient: mockApiClient)
        let expectation = expectation(description: "testFailedFetchArticlesWithNetwork")
        
        await testViewModel.onAppear()
        
        guard let stateObserver = testViewModel.stateObserver else {
            
            XCTFail()
            return
        }
        
        Task {
            
            await assertViewState(actualStateStream: stateObserver,
                                  expectedStateStream: [
                                    .initial(state: .init(user: normalTestUser)), // 初期状態
                                    .loading(type: .initial), // ロード中
                                    .alert(AlertCase.networkErrorWithRetry.getExecutorInstance()), // アラート表示
                                    .loading(type: .initial), // ロード中
                                    .alert(AlertCase.networkErrorWithRetry.getExecutorInstance()), // アラート表示
                                    .appeared(state: .init(user: normalTestUser)) // アラート非表示
                                  ],
                                  expectation: expectation)
        }
        
        await testViewModel.tappedRetryFetchArticlesButton()
        testViewModel.tappedCloseAlertButton()
        testViewModel.onDisappear()
        
        await fulfillment(of: [expectation], timeout: 5)
    }
    
    /// ユーザーIDが不正なため記事取得のURL取得に失敗したケースを確認
    ///
    /// # 仕様
    /// - URLの取得に失敗した場合は、想定外エラーのアラートを表示する
    /// - アラートの閉じるボタンを押下すると、アラートを閉じる
    func testFailedCreateFetchArticlesUrl() async throws {
        
        let invalidUserModel = QiitaUserModel(id: "[]{}^~¥だいk",
                                              name: "xxxxx",
                                              description: "ssssss",
                                              followeesCount: 2,
                                              followersCount: 8,
                                              profile_image_url: "https://qiita.com/stotic-dev/items/sssss")
        let testViewModel = QiitaUserDetailViewModel(userModel: invalidUserModel)
        let expectation = expectation(description: "testFailedFetchArticlesWithNetwork")
        
        await testViewModel.onAppear()
        
        guard let stateObserver = testViewModel.stateObserver else {
            
            XCTFail()
            return
        }
        
        Task {
            
            await assertViewState(actualStateStream: stateObserver,
                                  expectedStateStream: [
                                    .initial(state: .init(user: invalidUserModel)), // 初期状態
                                    .loading(type: .initial), // ロード中
                                    .alert(AlertCase.unexpectedError.getExecutorInstance()), // アラート表示
                                    .appeared(state: .init(user: invalidUserModel))
                                  ],
                                  expectation: expectation)
        }
        
        testViewModel.tappedCloseAlertButton()
        testViewModel.onDisappear()
        
        await fulfillment(of: [expectation], timeout: 5)
    }
    
    /// 取得した記事のURLが不正だったケースを確認
    ///
    /// # 仕様
    /// - タップした記事のURLがURL変換不可能の値であった場合は、想定外エラーのアラートを表示する
    func testFetchedInvalidArticleUrl() async throws {
        
        let expectedFetchedArticle = QiitaArticleModel(id: UUID().uuidString,
                                                       title: "invalid article",
                                                       tags: [],
                                                       likesCount: 3,
                                                       createdAt: Date.now,
                                                       url: "[アイウエオかきくけこ")
        let mockApiClient = try ApiClientMock<[QiitaArticleModel]>(expectedInput: [.fetchArticlesByUserId(userId: normalTestUser.id, page: 1)],
                                                               expectedResult: [.success([
                                                                expectedFetchedArticle
                                                               ])])
        let testViewModel = QiitaUserDetailViewModel(userModel: normalTestUser, apiClient: mockApiClient)
        let expectation = expectation(description: "testFetchedInvalidArticleUrl")
        
        await testViewModel.onAppear()
        
        guard let stateObserver = testViewModel.stateObserver else {
            
            XCTFail()
            return
        }
        
        Task {
            
            await assertViewState(actualStateStream: stateObserver,
                                  expectedStateStream: [
                                    .initial(state: .init(user: normalTestUser)), // 初期状態
                                    .loading(type: .initial), // ロード中
                                    .appeared(state: .init(user: normalTestUser, articleList: [expectedFetchedArticle])), // 記事取得
                                    .alert(AlertCase.unexpectedError.getExecutorInstance()), // 想定外エラーアラート表示
                                    .appeared(state: .init(user: normalTestUser, articleList: [expectedFetchedArticle])) // アラート非表示
                                  ],
                                  expectation: expectation)
        }
        
        testViewModel.tappedArticleCell(expectedFetchedArticle.id)
        testViewModel.tappedCloseAlertButton()
        testViewModel.onDisappear()
        
        await fulfillment(of: [expectation], timeout: 5)
    }
}
