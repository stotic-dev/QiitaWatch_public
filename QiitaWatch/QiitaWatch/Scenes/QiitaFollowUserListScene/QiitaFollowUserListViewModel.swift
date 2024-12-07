//
//  QiitaFollowUserListViewModel.swift
//  QiitaWatch
//
//  Created by 佐藤汰一 on 2024/11/20.
//

import Foundation

@MainActor
final class QiitaFollowUserListViewModel {
    
    // MARK: - public property
    
    private(set) var stateObserver: AsyncStream<ViewState>?
    
    // MARK: - private property
    
    // MARK: - dependency
    
    private let qiitaUserRepository: QiitaUserRepository
    
    // MARK: state
    
    private var continuation: AsyncStream<ViewState>.Continuation?
    // 現在取得済みユーザーのページ数
    private var currentFetchedPage = 1
    // 現在取得済みのユーザーリスト
    private var currentUserList: [QiitaUserModel] = []
    // 現在のユーザー取得状態
    private var fetchArticleState: FetchState = .none
    
    // MARK: constant
    
    // フォロー(フォロワー)を取得する対象のユーザーID
    private let targetUserId: String
    // 表示するユーザーの種類
    private let displayTarget: DisplayTarget
    
    // MARK: - initialize method
    
    init(targetUserId: String,
         displayTarget: DisplayTarget,
         apiClient: ApiClient = QiitaApiClientImpl()) {
        
        self.targetUserId = targetUserId
        self.displayTarget = displayTarget
        self.qiitaUserRepository = QiitaUserRepository(client: apiClient)
    }
    
    // MARK: - public method
    
    /// 画面表示時
    func onAppear() async {
        
        log.info("[In]")
        
        stateObserver = AsyncStream<ViewState> { [weak self] in
            
            self?.continuation = $0
            self?.continuation?.yield(.initial)
        }
        
        fetchArticleState = .initial
        await loadNewUserList()
    }
    
    /// 画面非表示時
    func onDissapper() {
        
        log.info("[In]")
        continuation?.finish()
    }
    
    /// ユーザーセルタップ時
    func tappedUserCell(userId: String) {
        
        log.info("[In] userId: \(userId)")
        guard let userModel = currentUserList.first(where: { $0.id == userId }) else {
            
            assertionFailure("Not found user in currentUserList(\(currentUserList))")
            return
        }
        continuation?.yield(.screenTransition(user: userModel))
    }
    
    /// 下から上へスワイプした時
    func pushToRefresh() async {
        
        log.info("[In]")
        fetchArticleState = .nextPageUserFetching
        await loadNextPageUserList()
    }
    
    /// 上から下へスワイプした時
    func pullToRefresh() async {
        
        log.info("[In] currentPage: \(currentFetchedPage)")
        fetchArticleState = .newUserFetching
        await loadNewUserList()
    }
    
    /// アラートのリトライボタン押下時
    func tappedRetryAlertButton() async {
        
        log.info("[In] fetchArticleState: \(fetchArticleState)")
        
        switch fetchArticleState {
            
        case .none: break
        case .initial, .newUserFetching:
            await loadNewUserList()
            
        case .nextPageUserFetching:
            await loadNextPageUserList()
        }
    }
    
    /// アラートの閉じるボタン押下時
    func tappedCloseAlertButton() {
        
        log.info("[In]")
        fetchArticleState = .none
        continuation?.yield(.appeared(state: .init(userList: convertQiitaModelToEntity(currentUserList))))
    }
}

// MARK: - private method

private extension QiitaFollowUserListViewModel {
    
    func loadNewUserList() async {
        
        continuation?.yield(.loading(type: fetchArticleState))
        
        do {
            
            let userList = switch displayTarget {
                
            case .followee:
                try await qiitaUserRepository.fetchFolloweeUsersByUserId(targetUserId,
                                                                         page: 1)
                
            case .follower:
                try await qiitaUserRepository.fetchFollowerUsersByUserId(targetUserId,
                                                                         page: 1)
            }
            
            log.debug("Completed fetching user list(\(userList)).")
            
            fetchArticleState = .none
            addUserList(userList)
            continuation?.yield(.appeared(state: .init(userList: convertQiitaModelToEntity(currentUserList))))
        }
        catch {
            
            log.error("Occurred error: \(error)")
            handleFetchUserListError(error)
        }
    }
    
    func loadNextPageUserList() async {
        
        continuation?.yield(.loading(type: fetchArticleState))
        
        do {
            
            let userList = switch displayTarget {
                
            case .followee:
                try await qiitaUserRepository.fetchFolloweeUsersByUserId(targetUserId,
                                                                         page: currentFetchedPage + 1)
                
            case .follower:
                try await qiitaUserRepository.fetchFollowerUsersByUserId(targetUserId,
                                                                         page: currentFetchedPage + 1)
            }
            
            currentFetchedPage += 1
            log.debug("Completed fetching user list(userList=\(userList), currentFetchedPage=\(currentFetchedPage).")
            
            fetchArticleState = .none
            addUserList(userList)
            continuation?.yield(.appeared(state: .init(userList: convertQiitaModelToEntity(currentUserList))))
        }
        catch {
            
            log.error("Occurred error: \(error)")
            handleFetchUserListError(error)
        }
    }
    
    func addUserList(_ fetchedUserList: [QiitaUserModel]) {
        
        var distinctUserList: [QiitaUserModel] = []
        
        fetchedUserList.forEach {
            
            if let needUpdateArticleIndex = currentUserList.firstIndex(of: $0) {
                
                // 同じユーザーを取得した場合は最新の記事に更新する
                currentUserList[needUpdateArticleIndex] = $0
                // 取得したユーザーから更新したユーザーを削除
                distinctUserList.append($0)
            }
        }
        
        // 重複しているユーザーはフィルタリングする
        let filteredFetchedUserList = fetchedUserList.filter { !distinctUserList.contains($0) }
        
        // 取得したユーザーを現在のユーザーリストに加えて、IDの昇順にソート
        currentUserList = currentUserList + filteredFetchedUserList
        currentUserList.sort { $0.id < $1.id }
        
        log.debug("Updated user list: \(currentUserList)")
    }
    
    func handleFetchUserListError(_ error: QiitaApiRepositoryError) {
        
        if error.isClientError {
            
            continuation?.yield(.alert(AlertCase.networkErrorWithRetry.getExecutorInstance()))
        }
        else {
            
            continuation?.yield(.alert(AlertCase.unexpectedError.getExecutorInstance()))
        }
    }
    
    func convertQiitaModelToEntity(_ models: [QiitaUserModel]) -> [UserEntity] {
        
        return models.map { .init(userId: $0.id,
                                  followeeCount: $0.followeesCount,
                                  followerCount: $0.followersCount,
                                  userIconImageUrl: URL(string: $0.profile_image_url,
                                                        encodingInvalidCharacters: false)) }
    }
}

extension QiitaFollowUserListViewModel {
    
    enum ViewState: Equatable {
        
        /// 初期状態
        case initial
        /// 画面表示中
        case appeared(state: ViewStateEntity)
        /// ロード中
        case loading(type: FetchState)
        /// 画面遷移中
        case screenTransition(user: QiitaUserModel)
        /// アラート表示中
        case alert(_ alertExecutor: AlertExecutor)
    }
    
    struct ViewStateEntity: Equatable {
        
        let userList: [UserEntity]
    }
    
    struct UserEntity: Equatable {
        
        /// ユーザーID
        let userId: String
        /// フォロー人数
        let followeeCount: Int
        /// フォロワー人数
        let followerCount: Int
        /// ユーザーアイコンのURL
        let userIconImageUrl: URL?
    }
    
    enum FetchState {
        
        /// 何も取得中でない
        case none
        /// 画面表示時のユーザー取得中
        case initial
        /// 新しいユーザーを取得中
        case newUserFetching
        /// 次ページのユーザーを取得中
        case nextPageUserFetching
    }
    
    enum DisplayTarget {
        
        /// フォローユーザー一覧
        case followee
        /// フォロワーユーザー一覧
        case follower
        
        var title: String {
            
            switch self {
                
            case .followee:
                "フォロー一覧画面"
            case .follower:
                "フォロワー一覧画面"
            }
        }
    }
}
