//
//  QiitaUserDetailViewModel.swift
//  QiitaWatch
//
//  Created by 佐藤汰一 on 2024/11/16.
//

import UIKit

@MainActor
final class QiitaUserDetailViewModel {
    
    // MARK: - public property
    
    private(set) var stateObserver: AsyncStream<ViewState>?
    
    // MARK: - private property
    
    // MARK: dependency
    
    private let qiitaArticleRepository: QiitaArticleRepository
    
    // MARK: state
    
    private var continuation: AsyncStream<ViewState>.Continuation?
    // 現在取得済み投稿記事のページ数
    private var currentFetchedPage = 1
    // 現在取得済みの投稿記事リスト
    private var currentArticles: [QiitaArticleModel] = []
    // 現在の記事取得状態
    private var fetchArticleState: FetchState = .none
    
    // MARK: constant
    
    private let userModel: QiitaUserModel
    
    // MARK: - initialize method
    
    init(userModel: QiitaUserModel, apiClient: ApiClient = QiitaApiClientImpl()) {
        
        self.userModel = userModel
        self.qiitaArticleRepository = QiitaArticleRepository(client: apiClient)
    }
    
    // MARK: - public method
    
    /// 画面表示時
    func onAppear() async {
        
        log.info("[In]")
        
        self.stateObserver = AsyncStream<ViewState> { [weak self] continuation in
            
            guard let self else { return }
            self.continuation = continuation
            continuation.yield(.initial(state: .init(user: self.userModel)))
        }
        
        fetchArticleState = .initial
        continuation?.yield(.loading(type: .initial))
        await loadNewArticles()
    }
    
    /// 画面非表示時
    func onDisappear() {
        
        log.info("[In]")
        continuation?.finish()
    }
    
    /// 記事のセルを押下時
    /// - Parameter id: 記事のID
    func tappedArticleCell(_ id: String) {
        
        log.info("articleId: \(id)")
        guard let selectArticle = currentArticles.first(where: { $0.id == id }) else {
            
            assertionFailure("Invalid article id.")
            return
        }
        
        if let articleUrl = URL(string: selectArticle.url, encodingInvalidCharacters: false) {
            
            continuation?.yield(.screenTransition(destination: .article(articleUrl)))
        }
        else {
            
            // 取得したURL文字列をURL型に変換できないケースは基本的に想定外であるが、
            // アプリの管理外の値であり起こり得ない保証がないので想定外のアラートを表示するようにする
            continuation?.yield(.alert(AlertCase.unexpectedError.getExecutorInstance()))
        }
    }
    
    /// フォロー人数ボタン押下時
    func tappedFolloweeButton() {
        
        log.info("[In]")
        continuation?.yield(.screenTransition(destination: .followee(userModel.id)))
    }
    
    /// フォロワー人数ボタン押下時
    func tappedFollowerButton() {
        
        log.info("[In]")
        continuation?.yield(.screenTransition(destination: .follwer(userModel.id)))
    }
    
    /// tableviewを上から下へスワイプをおこなった時
    func pullToRefresh() async {
        
        log.info("[In]")
        fetchArticleState = .nextPageArticlesFetching
        continuation?.yield(.loading(type: .newArticlesFetching))
        await loadNewArticles()
    }
    
    /// tableviewを下から上にスワイプをおこなった時
    func pushToRefresh() async {
        
        log.info("[In]")
        fetchArticleState = .newArticlesFetching
        continuation?.yield(.loading(type: .nextPageArticlesFetching))
        await loadFromNextPage()
    }
    
    /// 記事取得失敗アラートのリトライボタン押下時
    func tappedRetryFetchArticlesButton() async {
        
        log.info("current fetch state: \(fetchArticleState)")
        
        switch fetchArticleState {
            
        case .none: break
        case .initial:
            continuation?.yield(.loading(type: fetchArticleState))
            await loadNewArticles()
            
        case .newArticlesFetching:
            continuation?.yield(.loading(type: fetchArticleState))
            await loadNewArticles()
            
        case .nextPageArticlesFetching:
            continuation?.yield(.loading(type: fetchArticleState))
            await loadFromNextPage()
        }
    }
    
    /// アラート閉じるボタン押下時
    func tappedCloseAlertButton() {
        
        log.info("[In]")
        fetchArticleState = .none
        continuation?.yield(.appeared(state: .init(user: userModel, articleList: currentArticles)))
    }
}

private extension QiitaUserDetailViewModel {
    
    func loadFromNextPage() async {
                        
        do {
            
            let fetchedArticles = try await qiitaArticleRepository.fetchArticlesByUserId(userId: userModel.id,
                                                                                         page: currentFetchedPage + 1)
            
            log.debug("Fetched articles: \(fetchedArticles)")
            
            // 次ページの記事取得が完了したら、取得済みページを更新する
            currentFetchedPage += 1
            // 現在の記事リストを更新
            addArticles(fetchedArticles)
            // 取得完了したら取得状況をリセットする
            fetchArticleState = .none
            continuation?.yield(.appeared(state: .init(user: userModel,
                                                       articleList: currentArticles)))
        }
        catch {
            
            log.error("error: \(error)")
            continuation?.yield(.alert(getAlertExecutorOfError(error)))
        }
    }
    
    func loadNewArticles() async {
                
        do {
            
            let fetchedArticles = try await qiitaArticleRepository.fetchArticlesByUserId(userId: userModel.id,
                                                                                         page: 1)
            
            log.debug("Fetched articles: \(fetchedArticles)")
            
            // 現在の記事リストを更新
            addArticles(fetchedArticles)
            // 取得完了したら取得状況をリセットする
            fetchArticleState = .none
            continuation?.yield(.appeared(state: .init(user: userModel,
                                                       articleList: currentArticles)))
        }
        catch {
            
            log.error("error: \(error)")
            continuation?.yield(.alert(getAlertExecutorOfError(error)))
        }
    }
    
    func addArticles(_ fetchedArticles: [QiitaArticleModel]) {
        
        var distinctArticles: [QiitaArticleModel] = []
        
        fetchedArticles.forEach {
            
            if let needUpdateArticleIndex = currentArticles.firstIndex(of: $0) {
                
                // 同じ記事を取得した場合は最新の記事に更新する
                currentArticles[needUpdateArticleIndex] = $0
                // 取得した記事から更新した記事を削除
                distinctArticles.append($0)
            }
        }
        
        // 重複している記事はフィルタリングする
        let filteredFetchedArticles = fetchedArticles.filter { !distinctArticles.contains($0) }
        
        // 取得した記事を現在の記事リストに加えて、作成日時の降順にソート
        currentArticles = currentArticles + filteredFetchedArticles
        currentArticles.sort { $0.createdAt > $1.createdAt }
    }
    
    func getAlertExecutorOfError(_ error: QiitaApiRepositoryError) -> AlertExecutor {
        
        var alertCase: AlertCase
        
        if error.isClientError {
            
            alertCase = .networkErrorWithRetry
        }
        else {
            
            alertCase = .unexpectedError
        }
        
        return alertCase.getExecutorInstance()
    }
}

// MARK: - view state definition

extension QiitaUserDetailViewModel {
    
    enum ViewState: Equatable {
        
        /// 初期状態
        case initial(state: ViewStateEntity)
        /// 画面表示中
        case appeared(state: ViewStateEntity)
        /// ロード中
        case loading(type: FetchState)
        /// 画面遷移中
        case screenTransition(destination: Destination)
        /// アラート表示中
        case alert(_ alertExecutor: AlertExecutor)
    }
    
    struct ViewStateEntity: Equatable {
        
        /// ユーザー名
        let userId: String
        /// 紹介文
        let description: String
        /// フォロワー数
        let followerCount: Int
        /// フォロー数
        let followeeCount: Int
        /// アイコン画像URL
        let iconImageUrl: String
        /// 投稿記事リスト
        let articleList: [QiitaArticleModel]
        
        init(user: QiitaUserModel, articleList: [QiitaArticleModel] = []) {
            
            userId = user.id
            description = user.description
            followerCount = user.followersCount
            followeeCount = user.followeesCount
            iconImageUrl = user.profile_image_url
            self.articleList = articleList
        }
    }
    
    enum FetchState {
        
        /// 何も取得中でない
        case none
        /// 画面表示時の記事取得中
        case initial
        /// 新しい記事を取得中
        case newArticlesFetching
        /// 次ページの記事を取得中
        case nextPageArticlesFetching
    }
    
    enum Destination: Equatable {
        
        /// 記事表示画面
        case article(URL)
        /// フォロー画面
        case followee(String)
        /// フォロワー画面
        case follwer(String)
    }
}
