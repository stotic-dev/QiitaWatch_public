//
//  QiitaUserDetailViewController.swift
//  QiitaWatch
//
//  Created by 佐藤汰一 on 2024/11/16.
//

import UIKit

/// ユーザー詳細画面
///
/// # 仕様
/// - ユーザ情報を表示する
///   - 表示項目
///     - アイコン画像
///     - ユーザ名 (id)
///     - 自己紹介文
///     - フォロー数、フォロワー数
/// - フォロー数、フォロワー数をタップした場合にフォロー、フォロワー画面に遷移する
/// - 記事一覧を表示する
///   - API: https://qiita.com/api/v2/users/:uesr_id/items
///   - 表示項目
///     - タイトル
///     - タグ
///     - LGTM 数
///     - 投稿日時
/// - 記事のセルをタップした場合に記事表示画面に遷移する
final class QiitaUserDetailViewController: UIViewController {
    
    // MARK: - IBOutlet property
    
    @IBOutlet weak var userDetailTableView: UITableView!
    @IBOutlet weak var tableBottomRefreshIndicator: ProgressIndicatorView! {
        
        didSet {
            
            tableBottomRefreshIndicator.isHidden = true
        }
    }
    
    // MARK: - private property
    
    // MARK: viewModel
    
    private var viewModel: QiitaUserDetailViewModel?
    
    // MARK: state
    
    // 投稿記事リスト
    private var articleList: [QiitaArticleModel] = []
    // ユーザー詳細画面
    private var qiitaDetailView: QiitaUserDetailView?
    // ぐるぐる画面
    private var progressIndicator: ProgressIndicatorView?
    // tableViewのpullToRefresh用のコンポーネント
    private var tableViewRefresh = UIRefreshControl()
    // 現在ロード中の種別
    private var currentLoadingType: QiitaUserDetailViewModel.FetchState = .none
    
    // MARK: - factory method
    
    static func getInstance(user: QiitaUserModel) -> UIViewController {
        
        let viewController = UIStoryboard(name: "QiitaUserDetailScene", bundle: nil).instantiateViewController(withIdentifier: "QiitaUserDetailViewController")
        guard let qiitaUserDetailVC = viewController as? QiitaUserDetailViewController else { return viewController }
        qiitaUserDetailVC.viewModel = QiitaUserDetailViewModel(userModel: user)
        return qiitaUserDetailVC
    }
    
    // MARK: - deinit method
    
    deinit {
        
        log.trace()
    }
    
    // MARK: - lifecycle method
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        log.trace()
        
        setupTableView()
        setupBackgroundView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        setupNavigationBar()
        
        Task {
            
            await viewModel?.onAppear()
            
            guard let viewStateStream = viewModel?.stateObserver else {
                
                assertionFailure("Failed create view state observer.")
                return
            }
            addViewStateObserver(viewStateStream: viewStateStream)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        viewModel?.onDisappear()
    }
}

// MARK: - UITableView delegate

extension QiitaUserDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return articleList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: QiitaUserArticleViewCell.identifire) as? QiitaUserArticleViewCell else {
            
            assertionFailure("Failed create cell.")
            return UITableViewCell()
        }
        cell.setupCell(with: articleList[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        tableView.estimatedRowHeight = 100
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        viewModel?.tappedArticleCell(articleList[indexPath.row].id)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        return qiitaDetailView
    }
}

// MARK: - UIScrollView delegate method

extension QiitaUserDetailViewController {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        // 下部でロードをしていいか、判定する
        let contentSize = scrollView.contentSize.height
        let tableSize = scrollView.frame.size.height - scrollView.contentInset.top - scrollView.contentInset.bottom
        let canLoadFromBottom = contentSize > tableSize
        
        // Offset
        // 差分を計算して、 `<= -120.0` で、閾値を超えていればrefreshするようにする。
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        let difference = maximumOffset - currentOffset
        
        // Difference threshold as you like. -120.0 means pulling the cell up 120 points
        if canLoadFromBottom,
           difference <= -120.0,
           currentLoadingType == .none {
            
            currentLoadingType = .nextPageArticlesFetching
            Task {
                
                await viewModel?.pushToRefresh()
            }
        }
    }
}

// MARK: - QiitaUserDetailViewDelegate method

extension QiitaUserDetailViewController: QiitaUserDetailViewDelegate {
    
    func tappedFolloweeButton() {
        
        viewModel?.tappedFolloweeButton()
    }
    
    func tappedFollowerButton() {
        
        viewModel?.tappedFollowerButton()
    }
}

// MARK: - private method

private extension QiitaUserDetailViewController {
    
    // MARK: state update method
    
    func addViewStateObserver(viewStateStream: AsyncStream<QiitaUserDetailViewModel.ViewState>) {
        
        Task {
            
            for await state in viewStateStream {
                
                log.info("Received state: \(state)")
                
                switch state {
                    
                case .initial(let state):
                    setInitialViewState(state)
                    
                case .appeared(let state):
                    removeProgressIndicator()
                    updateViewState(state)
                    
                case .loading(let type):
                    showProgressIndicator(type)
                    
                case .screenTransition(let destination):
                    pushToNextScene(destination)
                    
                case .alert(let alertExecutor):
                    removeProgressIndicator()
                    alertExecutor.showAlert(target: self, firstHandler: { [weak self] in
                        
                        self?.viewModel?.tappedCloseAlertButton()
                    }, secondHandler: { [weak self] in
                        
                        Task {
                            
                            await self?.viewModel?.tappedRetryFetchArticlesButton()
                        }
                    })
                }
            }
        }
    }
    
    func setInitialViewState(_ viewState: QiitaUserDetailViewModel.ViewStateEntity) {
        
        let userDetailEntity = UserDetailEntity(iconImageUrl: URL(string: viewState.iconImageUrl, encodingInvalidCharacters: true),
                                                userId: viewState.userId,
                                                description: viewState.description,
                                                followeeCount: viewState.followeeCount,
                                                followerCount: viewState.followerCount)
        qiitaDetailView = QiitaUserDetailView.getInstance(userDetailEntity)
        qiitaDetailView?.delegate = self
        
        updateViewState(viewState)
    }
    
    func updateViewState(_ viewState: QiitaUserDetailViewModel.ViewStateEntity) {
        
        articleList = viewState.articleList
        userDetailTableView.reloadData()
    }
    
    func showProgressIndicator(_ type: QiitaUserDetailViewModel.FetchState) {
        
        currentLoadingType = type
        
        switch type {
            
        case .initial:
            progressIndicator = ProgressIndicatorView()
            view.addSubview(progressIndicator!)
            view.bringSubviewToFront(progressIndicator!)
            
            progressIndicator?.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                progressIndicator!.topAnchor.constraint(equalTo: view.topAnchor),
                progressIndicator!.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                progressIndicator!.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                progressIndicator!.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
            
        case .nextPageArticlesFetching:
            tableBottomRefreshIndicator.isHidden = false
            
        case .newArticlesFetching, .none:
            break
        }
    }
    
    func removeProgressIndicator() {
        
        log.debug("currentLoadingType: \(currentLoadingType)")
        
        switch currentLoadingType {
        
        case .none: break
        case .initial:
            guard let progressIndicator else { return }
            progressIndicator.removeFromSuperview()
            self.progressIndicator = nil
            
        case .nextPageArticlesFetching:
            tableBottomRefreshIndicator.isHidden = true
            
        case .newArticlesFetching:
            tableViewRefresh.endRefreshing()
        }
        
        currentLoadingType = .none
    }
    
    func pushToNextScene(_ destination: QiitaUserDetailViewModel.Destination) {
        
        log.info("Push to next scene: \(destination)")
        
        var nextVC: UIViewController
        
        switch destination {
            
        case .article(let articleUrl):
            nextVC = QiitaArticleViewController.getInstance(articleUrl)
            
        case .followee(let userId):
            nextVC = QiitaFollowUserListViewController.getInstance(userIdForFollowee: userId)
            
        case .follwer(let userId):
            nextVC = QiitaFollowUserListViewController.getInstance(userIdForFollower: userId)
        }
        
        navigationController?.pushViewController(nextVC, animated: true)
    }
    
    // MARK: view setup method
    
    func setupNavigationBar() {
        
        // ナビゲーションバーを表示にする
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationItem.title = "ユーザー詳細"
        
        if navigationController?.viewControllers.count == 1 {
            
            navigationItem.hidesBackButton = true
        }
        else {
            
            navigationItem.leftBarButtonItem = .getCommonNavigationBackButtonItem(target: self, action: #selector(tappedBackButton))
        }
    }
    
    func setupBackgroundView() {
        
        view.backgroundColor = .primaryBackgroundColor
    }
    
    func setupTableView() {
        
        userDetailTableView.delegate = self
        userDetailTableView.dataSource = self
        userDetailTableView.register(QiitaUserArticleViewCell.self,
                                     forCellReuseIdentifier: QiitaUserArticleViewCell.identifire)
        userDetailTableView.backgroundColor = .secondaryBackgroundColor
        userDetailTableView.sectionIndexBackgroundColor = .primaryBackgroundColor
        userDetailTableView.sectionHeaderTopPadding = .zero
        userDetailTableView.separatorStyle = .none
        userDetailTableView.tableFooterView = UIView()
        
        userDetailTableView.refreshControl = tableViewRefresh
        tableViewRefresh.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
    }
    
    // MARK: other method
    
    @objc func tappedBackButton() {
        
        navigationController?.popViewController(animated: true)
    }
    
    @objc func pullToRefresh() {
        
        Task {
            
            await viewModel?.pullToRefresh()
        }
    }
}
