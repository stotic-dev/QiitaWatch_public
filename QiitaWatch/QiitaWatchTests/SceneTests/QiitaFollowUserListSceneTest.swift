//
//  QiitaFollowUserListSceneTest.swift
//  QiitaWatchTests
//
//  Created by 佐藤汰一 on 2024/11/20.
//

import Alamofire
import XCTest

@testable import QiitaWatch

@MainActor
final class QiitaFollowUserListSceneTest: XCTestCase {
    
    // MARK: - 正常系
    
    /// フォロー一覧画面表示時の動作確認
    ///
    /// # 確認仕様
    /// - 画面を表示したらフォロー一覧情報を取得する
    /// - 情報を取得したらフォロー一覧情報を画面に渡す
    /// - ユーザリストのセルタップすると、タップしたユーザーの詳細画面へ遷移する
    func testOnAppearSceneOfFollowee() async throws {
        
        let expectedFetchResult = [
            QiitaUserModel(id: "aaaaaaa",
                           name: "test name1",
                           description: "xxxxxxxx",
                           followeesCount: 10,
                           followersCount: 100,
                           profile_image_url: "https://test.com/test.png"),
            QiitaUserModel(id: UUID().uuidString,
                           name: "bbbbb",
                           description: "xxxxxxxx",
                           followeesCount: 1,
                           followersCount: 0,
                           profile_image_url: "https://test.com/test.png")
        ]
        
        let expectedTargetUserId = UUID().uuidString
        let expectedTappedUserId = expectedFetchResult.first!.id
        
        let mockApiClient = try ApiClientMock(expectedInput:
                                                [.fetchQiitaFolloweeUsersService(userId: expectedTargetUserId, page: 1),
                                                 .fetchQiitaUsersService(keyword: expectedTappedUserId)
                                                ],
                                              expectedResult: [.success(expectedFetchResult)])
        let expectation = XCTestExpectation(description: "testOnAppearSceneOfFollowee")
        let testViewModel = QiitaFollowUserListViewModel(targetUserId: expectedTargetUserId,
                                                         displayTarget: .followee,
                                                         apiClient: mockApiClient)
        
        await testViewModel.onAppear()
        
        Task {
            
            await assertViewState(actualStateStream: testViewModel.stateObserver!,
                                  expectedStateStream: [
                                    .initial, // 初期
                                    .loading(type: .initial), // ロード中
                                    .appeared(state: .init(userList: convertQiitaUserModelToViewModelEntity(expectedFetchResult))), // ユーザーリスト表示
                                    .screenTransition(user: expectedFetchResult.first!) // 画面遷移
                                  ],
                                  expectation: expectation)
        }
        
        testViewModel.tappedUserCell(userId: expectedTappedUserId)
        testViewModel.onDissapper()
        
        await fulfillment(of: [expectation], timeout: 5)
    }
    
    /// フォロワー一覧画面表示時の動作確認
    ///
    /// # 確認仕様
    /// - 画面を表示したらフォロワー一覧情報を取得する
    /// - 情報を取得したらフォロワー一覧情報を画面に渡す
    func testOnAppearSceneOfFollower() async throws {
        
        let expectedFetchResult = [
            QiitaUserModel(id: "aaaaaaa",
                           name: "test name1",
                           description: "xxxxxxxx",
                           followeesCount: 10,
                           followersCount: 100,
                           profile_image_url: "https://test.com/test.png"),
            QiitaUserModel(id: "bbbbbb",
                           name: "test name2",
                           description: "xxxxxxxx",
                           followeesCount: 1,
                           followersCount: 0,
                           profile_image_url: "https://test.com/test.png")
        ]
        
        let expectedTargetUserId = UUID().uuidString
        
        let mockApiClient = try ApiClientMock(expectedInput: [.fetchQiitaFollowerUsersService(userId: expectedTargetUserId, page: 1)],
                                              expectedResult: [.success(expectedFetchResult)])
        let expectation = XCTestExpectation(description: "testOnAppearSceneOfFollower")
        let testViewModel = QiitaFollowUserListViewModel(targetUserId: expectedTargetUserId,
                                                         displayTarget: .follower,
                                                         apiClient: mockApiClient)
        
        await testViewModel.onAppear()
        
        Task {
            
            await assertViewState(actualStateStream: testViewModel.stateObserver!,
                                  expectedStateStream: [
                                    .initial, // 初期
                                    .loading(type: .initial), // ロード中
                                    .appeared(state: .init(userList: convertQiitaUserModelToViewModelEntity(expectedFetchResult))) // ユーザーリスト表示
                                  ],
                                  expectation: expectation)
        }
        
        testViewModel.onDissapper()
        
        await fulfillment(of: [expectation], timeout: 5)
    }
    
    /// ユーザーリストを上下にスワイプした時の動作を確認
    ///
    /// # 確認仕様
    /// - リストの最上部で上から下にスワイプした時に、1ページ目のユーザー情報を更新する
    /// - リストの最下部で下から上にスワイプした時に、次ページのユーザー情報を取得する
    /// - スワイプして更新されたユーザーリスト情報を画面に渡す
    func testSwipeList() async throws {
        
        let expectedInitialFetchResult = [
            QiitaUserModel(id: "bbbbbb",
                           name: "test name1",
                           description: "xxxxxxxx",
                           followeesCount: 10,
                           followersCount: 100,
                           profile_image_url: "https://test.com/test.png"),
            QiitaUserModel(id: "ccccc",
                           name: "test name2",
                           description: "xxxxxxxx",
                           followeesCount: 1,
                           followersCount: 0,
                           profile_image_url: "https://test.com/test.png")
        ]
        
        let expectedPullToRefreshFetchResult = expectedInitialFetchResult + [
            QiitaUserModel(id: "aaaaaa",
                           name: "aaaaaa",
                           description: "xxxxxxxx",
                           followeesCount: 0,
                           followersCount: 8,
                           profile_image_url: "https://test.com/test.png"),
        ]
        
        let expectedPushToRefreshFetchResult = [
            QiitaUserModel(id: "ddddddd",
                           name: "ddddddd",
                           description: "xxxxxxxx",
                           followeesCount: 10,
                           followersCount: 1000,
                           profile_image_url: "https://test.com/test.png"),
            QiitaUserModel(id: "eeeeee",
                           name: "eeeeee",
                           description: "xxxxxxxx",
                           followeesCount: 1,
                           followersCount: 999,
                           profile_image_url: "https://test.com/test.png")
        ]
        
        let expectedTargetUserId = UUID().uuidString
        
        let mockApiClient = try ApiClientMock(expectedInput: [
            .fetchQiitaFollowerUsersService(userId: expectedTargetUserId, page: 1),
            .fetchQiitaFollowerUsersService(userId: expectedTargetUserId, page: 1),
            .fetchQiitaFollowerUsersService(userId: expectedTargetUserId, page: 2)
        ],
                                              expectedResult: [
                                                .success(expectedInitialFetchResult),
                                                .success(expectedPullToRefreshFetchResult),
                                                .success(expectedPushToRefreshFetchResult)
                                              ])
        let expectation = XCTestExpectation(description: "testSwipeList")
        let testViewModel = QiitaFollowUserListViewModel(targetUserId: expectedTargetUserId,
                                                         displayTarget: .follower,
                                                         apiClient: mockApiClient)
        
        await testViewModel.onAppear()
        
        Task {
            
            await assertViewState(actualStateStream: testViewModel.stateObserver!,
                                  expectedStateStream: [
                                    .initial, // 初期
                                    .loading(type: .initial), // ロード中
                                    .appeared(state: .init(userList: convertQiitaUserModelToViewModelEntity(expectedInitialFetchResult))), // ユーザーリスト表示
                                    .loading(type: .newUserFetching), // ロード中
                                    .appeared(state: .init(userList: convertQiitaUserModelToViewModelEntity(expectedPullToRefreshFetchResult))), // ユーザーリスト表示
                                    .loading(type: .nextPageUserFetching), // ロード中
                                    .appeared(state: .init(userList: convertQiitaUserModelToViewModelEntity(expectedPullToRefreshFetchResult + expectedPushToRefreshFetchResult))) // ユーザーリスト表示
                                  ],
                                  expectation: expectation)
        }
        
        await testViewModel.pullToRefresh()
        await testViewModel.pushToRefresh()
        testViewModel.onDissapper()
        
        await fulfillment(of: [expectation], timeout: 5)
    }
    
    // MARK: - 異常系
    
    /// ユーザー情報の取得時にAPIクライアント関連で失敗した場合の確認
    ///
    /// # 確認仕様
    /// - 画面表示時にユーザー情報取得失敗した場合に、失敗した旨のアラートを表示する
    /// - アラートのリトライボタンを押下すると、アラートを閉じて再度ユーザー情報を取得する
    /// - アラートの閉じるボタンを押下すると、アラートを閉じる
    func testFailedFetchUserList() async throws {
        
        let expectedTargetUserId = UUID().uuidString
        
        let mockApiClient = try ApiClientMock<[QiitaUserModel]>(expectedInput: [
            .fetchQiitaFollowerUsersService(userId: expectedTargetUserId, page: 1),
            .fetchQiitaFollowerUsersService(userId: expectedTargetUserId, page: 1),
        ],
                                              expectedResult: [
                                                .failure(AFError.explicitlyCancelled),
                                                .failure(AFError.explicitlyCancelled),
                                              ])
        let expectation = XCTestExpectation(description: "testFailedFetchUserList")
        let testViewModel = QiitaFollowUserListViewModel(targetUserId: expectedTargetUserId,
                                                         displayTarget: .follower,
                                                         apiClient: mockApiClient)
        
        await testViewModel.onAppear()
        
        Task {
            
            await assertViewState(actualStateStream: testViewModel.stateObserver!,
                                  expectedStateStream: [
                                    .initial, // 初期
                                    .loading(type: .initial), // ロード中
                                    .alert(AlertCase.networkErrorWithRetry.getExecutorInstance()), // アラート表示
                                    .loading(type: .initial), // ロード中
                                    .alert(AlertCase.networkErrorWithRetry.getExecutorInstance()), // アラート表示
                                    .appeared(state: .init(userList: [])) // からのユーザーリスト表示
                                  ],
                                  expectation: expectation)
        }
        
        await testViewModel.tappedRetryAlertButton()
        testViewModel.tappedCloseAlertButton()
        testViewModel.onDissapper()
        
        await fulfillment(of: [expectation], timeout: 5)
    }
    
    /// PullToRefreshでユーザー情報の取得時にAPIクライアント関連で失敗した場合の確認
    ///
    /// # 確認仕様
    /// - PullToRefreshで情報取得に失敗した場合に、失敗した旨のアラートを表示する
    /// - アラートのリトライボタンを押下すると、アラートを閉じて再度PullToRefreshで対象となるユーザー情報を取得する
    /// - アラートの閉じるボタンを押下すると、アラートを閉じる
    func testFailedPullToRefreshByApiClient() async throws {
        
        let expectedInitialFetchResult = [
            QiitaUserModel(id: "aaaaa",
                           name: "aaaaa",
                           description: "xxxxxxxx",
                           followeesCount: 10,
                           followersCount: 100,
                           profile_image_url: "https://test.com/test.png"),
            QiitaUserModel(id: "bbbbbb",
                           name: "bbbbbb",
                           description: "xxxxxxxx",
                           followeesCount: 1,
                           followersCount: 0,
                           profile_image_url: "https://test.com/test.png")
        ]
        
        let expectedTargetUserId = UUID().uuidString
        
        let mockApiClient = try ApiClientMock(expectedInput: [
            .fetchQiitaFollowerUsersService(userId: expectedTargetUserId, page: 1),
            .fetchQiitaFollowerUsersService(userId: expectedTargetUserId, page: 1),
            .fetchQiitaFollowerUsersService(userId: expectedTargetUserId, page: 1),
        ],
                                              expectedResult: [
                                                .success(expectedInitialFetchResult),
                                                .failure(AFError.explicitlyCancelled),
                                                .failure(AFError.explicitlyCancelled),
                                              ])
        let expectation = XCTestExpectation(description: "testFailedPullToRefreshByApiClient")
        let testViewModel = QiitaFollowUserListViewModel(targetUserId: expectedTargetUserId,
                                                         displayTarget: .follower,
                                                         apiClient: mockApiClient)
        
        await testViewModel.onAppear()
        
        Task {
            
            await assertViewState(actualStateStream: testViewModel.stateObserver!,
                                  expectedStateStream: [
                                    .initial, // 初期
                                    .loading(type: .initial), // ロード中
                                    .appeared(state: .init(userList: convertQiitaUserModelToViewModelEntity(expectedInitialFetchResult))), // ユーザーリスト表示
                                    .loading(type: .newUserFetching), // ロード中
                                    .alert(AlertCase.networkErrorWithRetry.getExecutorInstance()), // アラート表示
                                    .loading(type: .newUserFetching), // ロード中
                                    .alert(AlertCase.networkErrorWithRetry.getExecutorInstance()), // アラート表示
                                    .appeared(state: .init(userList: convertQiitaUserModelToViewModelEntity(expectedInitialFetchResult))) // ユーザーリスト表示
                                  ],
                                  expectation: expectation)
        }
        
        await testViewModel.pullToRefresh()
        await testViewModel.tappedRetryAlertButton()
        testViewModel.tappedCloseAlertButton()
        testViewModel.onDissapper()
        
        await fulfillment(of: [expectation], timeout: 5)
    }
    
    /// PushToRefreshでユーザー情報の取得時にAPIクライアント関連で失敗した場合の確認
    ///
    /// # 確認仕様
    /// - PushToRefreshで情報取得に失敗した場合に、失敗した旨のアラートを表示する
    /// - アラートのリトライボタンを押下すると、アラートを閉じて再度PushToRefreshで対象となるユーザー情報を取得する
    /// - アラートの閉じるボタンを押下すると、アラートを閉じる
    func testFailedPushToRefreshByApiClient() async throws {
        
        let expectedInitialFetchResult = [
            QiitaUserModel(id: "aaaaa",
                           name: "aaaaa",
                           description: "xxxxxxxx",
                           followeesCount: 10,
                           followersCount: 100,
                           profile_image_url: "https://test.com/test.png"),
            QiitaUserModel(id: "bbbbbb",
                           name: "bbbbbb",
                           description: "xxxxxxxx",
                           followeesCount: 1,
                           followersCount: 0,
                           profile_image_url: "https://test.com/test.png")
        ]
        
        let expectedTargetUserId = UUID().uuidString
        
        let mockApiClient = try ApiClientMock(expectedInput: [
            .fetchQiitaFollowerUsersService(userId: expectedTargetUserId, page: 1),
            .fetchQiitaFollowerUsersService(userId: expectedTargetUserId, page: 2),
            .fetchQiitaFollowerUsersService(userId: expectedTargetUserId, page: 2),
        ],
                                              expectedResult: [
                                                .success(expectedInitialFetchResult),
                                                .failure(AFError.explicitlyCancelled),
                                                .failure(AFError.explicitlyCancelled),
                                              ])
        let expectation = XCTestExpectation(description: "testFailedPushToRefreshByApiClient")
        let testViewModel = QiitaFollowUserListViewModel(targetUserId: expectedTargetUserId,
                                                         displayTarget: .follower,
                                                         apiClient: mockApiClient)
        
        await testViewModel.onAppear()
        
        Task {
            
            await assertViewState(actualStateStream: testViewModel.stateObserver!,
                                  expectedStateStream: [
                                    .initial, // 初期
                                    .loading(type: .initial), // ロード中
                                    .appeared(state: .init(userList: convertQiitaUserModelToViewModelEntity(expectedInitialFetchResult))), // ユーザーリスト表示
                                    .loading(type: .nextPageUserFetching), // ロード中
                                    .alert(AlertCase.networkErrorWithRetry.getExecutorInstance()), // アラート表示
                                    .loading(type: .nextPageUserFetching), // ロード中
                                    .alert(AlertCase.networkErrorWithRetry.getExecutorInstance()), // アラート表示
                                    .appeared(state: .init(userList: convertQiitaUserModelToViewModelEntity(expectedInitialFetchResult))) // ユーザーリスト表示
                                  ],
                                  expectation: expectation)
        }
        
        await testViewModel.pushToRefresh()
        await testViewModel.tappedRetryAlertButton()
        testViewModel.tappedCloseAlertButton()
        testViewModel.onDissapper()
        
        await fulfillment(of: [expectation], timeout: 5)
    }
    
    /// ユーザー情報の取得時にURLの取得に失敗した場合の確認
    ///
    /// # 確認仕様
    /// - ユーザー情報取得処理でURLの取得に失敗した場合に、失敗した旨のアラートを表示する
    /// - アラートの閉じるボタンを押下すると、アラートを閉じる
    func testFailedFetchUserListByInvalidUrl() async throws {
        
        let expectedTargetUserId = "{}[]-^~¥|"
        
        let expectation = XCTestExpectation(description: "testFailedFetchUserListByInvalidUrl")
        let testViewModel = QiitaFollowUserListViewModel(targetUserId: expectedTargetUserId,
                                                         displayTarget: .follower)
        
        await testViewModel.onAppear()
        
        Task {
            
            await assertViewState(actualStateStream: testViewModel.stateObserver!,
                                  expectedStateStream: [
                                    .initial, // 初期
                                    .loading(type: .initial), // ロード中
                                    .alert(AlertCase.unexpectedError.getExecutorInstance()), // アラート表示
                                    .appeared(state: .init(userList: [])) // からのユーザーリスト表示
                                  ],
                                  expectation: expectation)
        }
        
        testViewModel.tappedCloseAlertButton()
        testViewModel.onDissapper()
        
        await fulfillment(of: [expectation], timeout: 5)
    }
}

private extension QiitaFollowUserListSceneTest {
    
    func convertQiitaUserModelToViewModelEntity(_ users: [QiitaUserModel]) -> [QiitaFollowUserListViewModel.UserEntity] {
        
        var users = users
        users.sort { $0.id < $1.id }
        return users.map { .init(userId: $0.id,
                                 followeeCount: $0.followeesCount,
                                 followerCount: $0.followersCount,
                                 userIconImageUrl: URL(string: $0.profile_image_url,
                                                       encodingInvalidCharacters: false)) }
    }
}
