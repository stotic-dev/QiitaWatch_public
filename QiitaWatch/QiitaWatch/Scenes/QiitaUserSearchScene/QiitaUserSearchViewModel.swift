//
//  QiitaUserSearchViewModel.swift
//  QiitaWatch
//
//  Created by 佐藤汰一 on 2024/11/14.
//

import SwiftData

@MainActor
final class QiitaUserSearchViewModel {
    
    // MARK: - public property
    
    private(set) var stateObserver: AsyncStream<ViewState>?
    
    // MARK: - private property
    
    private var continuation: AsyncStream<ViewState>.Continuation?
    /// 入力中の検索文字
    private var searchText = ""
    /// 過去の検索文字のモデルリスト
    private var searchWordModelList: [SearchWordModel] = [] {
        
        didSet {
            
            wordList = searchWordModelList.map { $0.word }
        }
    }
    /// 過去の検索文字リスト
    private var wordList: [String] = []
    
    // MARK: dependency
    
    private let searchWordRepository: SearchWordRepository
    private let qiitaUserRepository: QiitaUserRepository
    
    // MARK: - initialize method
    
    init(context: ModelContext, apiClient: ApiClient = QiitaApiClientImpl()) {
        
        self.searchWordRepository = SearchWordRepository(context: context)
        self.qiitaUserRepository = QiitaUserRepository(client: apiClient)
    }
    
    // MARK: - event
    
    /// 画面表示前の処理
    func onAppear() {
        
        log.info("[In]")
        
        self.stateObserver = AsyncStream { [weak self] continuation in
            
            self?.continuation = continuation
            continuation.yield(.initial(state: .initial))
        }
        
        // 過去の検索ワードを取得
        searchWordModelList = fetchCurrentSearchWordList()
        continuation?.yield(.appeared(state: ViewStateEntity(searchText: searchText,
                                                             postSearchTextList: wordList)))
    }
    
    /// 画面非表示時の処理
    func onDissapper() {
        
        log.info("[In]")
        continuation?.finish()
    }
    
    /// 検索テキストフィールドに文字入力時の処理
    func didEnterTextField(_ text: String) {
        
        log.info("[In] text: \(text)")
        searchText = text
        continuation?.yield(.appeared(state: .init(searchText: text, postSearchTextList: wordList)))
    }
    
    /// 検索ボタンタップ時のボタン
    func tappedSearchButton() async {
        
        log.info("Start loading.")
        continuation?.yield(.loading)
        
        // 入力した文字を保存して最新の検索リストを取得する
        saveSearchWord(searchText)
        searchWordModelList = fetchCurrentSearchWordList()
        
        do {
            
            let fetchedUser = try await qiitaUserRepository.fetchByUserId(searchText)
            
            log.debug("Complete fetched user: \(fetchedUser).")
            continuation?.yield(.screenTransition(user: fetchedUser))
        }
        catch {
            
            handleFetchQiitaUserError(error)
        }
    }
    
    /// アラートの閉じるボタン押下時
    func tappedCloseAlertButton() {
        
        continuation?.yield(.appeared(state: .init(searchText: searchText,
                                                    postSearchTextList: wordList)))
    }
}

// MARK: - private method

private extension QiitaUserSearchViewModel {
    
    func handleFetchQiitaUserError(_ error: QiitaApiRepositoryError) {
        
        var alertCase: AlertCase
        
        log.error("error: \(error)")
        
        if error.isNoHitUserError {
            
            alertCase = .noHitQiitaUser
        }
        else {
            
            alertCase = .networkError
        }
        
        continuation?.yield(.alert(alertCase.getExecutorInstance()))
    }
    
    func fetchCurrentSearchWordList() -> [SearchWordModel] {
        
        return (try? searchWordRepository.fetchAll()) ?? []
    }
    
    func saveSearchWord(_ text: String) {
        
        do {
            
            try searchWordRepository.insertOrUpdate(text)
            log.info("Complete insert or update(text=\(text)).")
        }
        catch {
            
            log.error("Failed update: \(error).")
        }
    }
}

// MARK: - view state definition

extension QiitaUserSearchViewModel {
    
    enum ViewState: Equatable {
        
        /// 初期状態
        case initial(state: ViewStateEntity)
        /// 画面表示中
        case appeared(state: ViewStateEntity)
        /// ロード中
        case loading
        /// 画面遷移中
        case screenTransition(user: QiitaUserModel)
        /// アラート表示中
        case alert(_ alert: AlertExecutor)
    }
    
    struct ViewStateEntity: Equatable {
        
        /// 検索ボタンが使用可能か
        let isEnabledSearchButton: Bool
        /// 過去の検索ワード
        let postSearchTextList: [String]
        
        static let initial = ViewStateEntity(isEnabledSearchButton: false)
        
        init(isEnabledSearchButton: Bool, postSearchTextList: [String] = []) {
            
            self.isEnabledSearchButton = isEnabledSearchButton
            self.postSearchTextList = postSearchTextList
        }
        
        init(searchText: String, postSearchTextList: [String] = []) {
            
            self.isEnabledSearchButton = !searchText.isEmpty
            self.postSearchTextList = postSearchTextList
        }
    }
}
