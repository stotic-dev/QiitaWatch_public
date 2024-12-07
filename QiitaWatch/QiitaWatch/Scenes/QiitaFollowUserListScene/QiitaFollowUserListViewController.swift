//
//  QiitaFollowUserListViewController.swift
//  QiitaWatch
//
//  Created by 佐藤汰一 on 2024/11/20.
//

import UIKit

/// フォロー(フォロワー)一覧画面
///
/// # 仕様
/// - フォロー (フォロワー) の一覧を表示する
///   - API
///     - followee: GET https://qiita.com/api/v2/users/:user_id/followees
///     - follower: GET https://qiita.com/api/v2/users/:user_id/followers
///   - 表示項目
///   - アイコン画像
///   - ユーザ名 (id)
///   - フォロー数
///   - フォロワー数
/// - セルをタップした場合にユーザー詳細画面に遷移する
final class QiitaFollowUserListViewController: UIViewController {
    
    // MARK: - IBOutlet property
    
    @IBOutlet weak var followUserListTableView: UITableView!
    @IBOutlet weak var tableBottomProgressIndicator: ProgressIndicatorView! {
        
        didSet {
            
            tableBottomProgressIndicator.isHidden = true
        }
    }
    
    // MARK: - private property
    
    // MARK: view model
    
    // MARK: state
    
    private var viewModel: QiitaFollowUserListViewModel?
    private var userList: [QiitaFollowUserListViewModel.UserEntity] = []
    private var displayTarget: QiitaFollowUserListViewModel.DisplayTarget = .followee
    private var currentLoadingState: QiitaFollowUserListViewModel.FetchState = .none
    private var tableRefresh = UIRefreshControl()
    private var progressIndicator: ProgressIndicatorView?
    
    // MARK: - factory method
    
    /// フォロー画面表示用のfactory method
    static func getInstance(userIdForFollowee: String) -> UIViewController {
        
        let viewController = UIStoryboard(name: "QiitaFollowUserListScene", bundle: nil).instantiateViewController(withIdentifier: "QiitaFollowUserListViewController")
        guard let qiitaFollowUserListViewController = viewController as? QiitaFollowUserListViewController else {
            
            return viewController
        }
        
        qiitaFollowUserListViewController.displayTarget = .followee
        qiitaFollowUserListViewController.viewModel = QiitaFollowUserListViewModel(targetUserId: userIdForFollowee,
                                                                                   displayTarget: .followee)
        return qiitaFollowUserListViewController
    }
    
    /// フォロワー画面表示用のfactory method
    static func getInstance(userIdForFollower: String) -> UIViewController {
        
        let viewController = UIStoryboard(name: "QiitaFollowUserListScene", bundle: nil).instantiateViewController(withIdentifier: "QiitaFollowUserListViewController")
        guard let qiitaFollowUserListViewController = viewController as? QiitaFollowUserListViewController else {
            
            return viewController
        }
        
        qiitaFollowUserListViewController.displayTarget = .follower
        qiitaFollowUserListViewController.viewModel = QiitaFollowUserListViewModel(targetUserId: userIdForFollower,
                                                                                   displayTarget: .follower)
        return qiitaFollowUserListViewController
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
            
            guard let stream = viewModel?.stateObserver else {
                
                assertionFailure("Failed create state observer.")
                return
            }
            
            addViewStateObserver(stream)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        viewModel?.onDissapper()
    }
}

// MARK: - UITableViewDelegate method

extension QiitaFollowUserListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return userList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: QiitaFollowUserListTableViewCell.identifire) as? QiitaFollowUserListTableViewCell else {
            
            return UITableViewCell()
        }
        
        cell.setUserEntity(userList[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        viewModel?.tappedUserCell(userId: userList[indexPath.row].userId)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 100
    }
}

// MARK: - UIScrollViewDelegate method

extension QiitaFollowUserListViewController: UIScrollViewDelegate {
    
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
           currentLoadingState == .none {
            
            currentLoadingState = .nextPageUserFetching
            Task {
                
                await viewModel?.pushToRefresh()
            }
        }
    }
}

// MARK: - private method

private extension QiitaFollowUserListViewController {
    
    // MARK: - view state update method
    
    func addViewStateObserver(_ viewStateStream: AsyncStream<QiitaFollowUserListViewModel.ViewState>) {
        
        Task {
            
            for await state in viewStateStream {
                
                switch state {
                    
                case .initial: break
                case .appeared(let state):
                    removeProgressIndicator()
                    updateUserList(state.userList)
                    
                case .loading(let type):
                    showProgressIndicator(type)
                    
                case .screenTransition(let user):
                    removeProgressIndicator()
                    showUserDetailScene(user)
                    
                case .alert(let executor):
                    removeProgressIndicator()
                    showAlert(executor)
                }
            }
        }
    }
    
    func updateUserList(_ entities: [QiitaFollowUserListViewModel.UserEntity]) {
        
        userList = entities
        followUserListTableView.reloadData()
    }
    
    func showProgressIndicator(_ type: QiitaFollowUserListViewModel.FetchState) {
        
        currentLoadingState = type
        
        switch type {
        case .none, .newUserFetching: break
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
            
        case .nextPageUserFetching:
            tableBottomProgressIndicator.isHidden = false
        }
    }
    
    func removeProgressIndicator() {
        
        switch currentLoadingState {
            
        case .none: break
        case .initial:
            progressIndicator?.removeFromSuperview()
            progressIndicator = nil
            
        case .newUserFetching:
            tableRefresh.endRefreshing()
            
        case .nextPageUserFetching:
            tableBottomProgressIndicator.isHidden = true
        }
        
        currentLoadingState = .none
    }
    
    func showUserDetailScene(_ user: QiitaUserModel) {
        
        let userDetailViewController = QiitaUserDetailViewController.getInstance(user: user)
        self.present(UINavigationController(rootViewController: userDetailViewController),
                     animated: true)
    }
    
    func showAlert(_ alertExecutor: AlertExecutor) {
        
        alertExecutor.showAlert(target: self, firstHandler: { [weak self] in
            
            self?.viewModel?.tappedCloseAlertButton()
        }, secondHandler: { [weak self] in
            
            Task {
                
                await self?.viewModel?.tappedRetryAlertButton()
            }
        })
    }
    
    // MARK: - setup method
    
    func setupNavigationBar() {
        
        // ナビゲーションバーを表示にする
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationItem.title = displayTarget.title
        navigationItem.leftBarButtonItem = .getCommonNavigationBackButtonItem(target: self, action: #selector(tappedBackButton))
    }
    
    func setupBackgroundView() {
        
        view.backgroundColor = .primaryBackgroundColor
    }
    
    func setupTableView() {
        
        followUserListTableView.delegate = self
        followUserListTableView.dataSource = self
        followUserListTableView.register(QiitaFollowUserListTableViewCell.self,
                                     forCellReuseIdentifier: QiitaFollowUserListTableViewCell.identifire)
        followUserListTableView.backgroundColor = .secondaryBackgroundColor
        followUserListTableView.sectionIndexBackgroundColor = .primaryBackgroundColor
        followUserListTableView.sectionHeaderTopPadding = .zero
        followUserListTableView.separatorStyle = .none
        followUserListTableView.tableFooterView = UIView()
        
        followUserListTableView.refreshControl = tableRefresh
        tableRefresh.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
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
