//
//  QiitaUserSearchViewController.swift
//  QiitaWatch
//
//  Created by 佐藤汰一 on 2024/11/13.
//

import UIKit

/// ユーザー検索画面
///
/// # 仕様
/// - ユーザ ID の入力を受け付ける
/// - 検索ボタンタップで
/// - ユーザ情報取得を試みる
///   - API: GET https://qiita.com/api/v2/users/:user_id
/// - 正常時にはユーザー情報画面にて検索結果を表示
/// - 異常時にはエラーをダイアログなどで表示
/// - 過去利用した検索ワードをテーブルで列挙
final class QiitaUserSearchViewController: UIViewController {
    
    // MARK: - IBOutlet property
    
    @IBOutlet weak var searchUserTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var wordListTableView: UITableView!
    
    // MARK: - private property
    
    private var viewModel: QiitaUserSearchViewModel?
    
    // MARK: state property
    
    // 過去の検索ワード表示用の検索ワードリスト
    private var wordList: [String] = []
    // ぐるぐる
    private var progressIndicator: ProgressIndicatorView?
    
    // MARK: constant property
    
    // 過去の検索ワードテーブルのCellID
    private let wordListCellIdentifier: String = "SearchWordTableViewCell"
    private let wordListCellHeight: CGFloat = 50
    
    // MARK: - factory method
    
    static func getInstance() -> UIViewController {
        
        let viewController = UIStoryboard(name: "QiitaUserSearchScene",
                                          bundle: nil)
            .instantiateViewController(withIdentifier: "QiitaUserSearchViewController")
        guard let qiitaUserSearchViewController = viewController as? QiitaUserSearchViewController,
              let context = AppDelegate.getDatabaseContainer()?.mainContext else { return viewController }
        qiitaUserSearchViewController.viewModel = QiitaUserSearchViewModel(context: context)
        return qiitaUserSearchViewController
    }
    
    // MARK: - initialize method
    
    deinit {
        
        log.trace()
    }
    
    // MARK: - lifecycle method

    override func viewDidLoad() {
        
        super.viewDidLoad()
        log.trace()
        
        setupBackgroundView()
        setupTableView()
        setupSearchUserTextFiled()
        setupSearchButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        setupNavigationBar()
        viewModel?.onAppear()
        
        guard let stream = viewModel?.stateObserver else {
            
            assertionFailure("Failed create viewModel instance.")
            return
        }
        
        // Stateの監視
        addObserveViewState(stream)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        log.trace()
        
        viewModel?.onDissapper()
    }
}

// MARK: - UITableView delegate method

extension QiitaUserSearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return wordList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: wordListCellIdentifier) else {
            
            assertionFailure("Failed create wordListCell instance.")
            return UITableViewCell()
        }
        
        var config = cell.defaultContentConfiguration()
        config.text = wordList[indexPath.row]
        config.textProperties.font = .projectFont(.medium)
        config.textProperties.color = .primaryTextColor
        cell.contentConfiguration = config
        cell.selectionStyle = .none
        cell.backgroundConfiguration?.backgroundColor = .primaryBackgroundColor
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return wordListCellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let text = wordList[indexPath.row]
        log.info("Tapped cell(index=\(indexPath), text=\(text)).")
        searchUserTextField.text = text
        viewModel?.didEnterTextField(text)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return "過去の検索ワード"
    }
}

// MARK: - UITextFiled delegate method

extension QiitaUserSearchViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.endEditing(true)
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        
        guard let inputText = textField.text else {
            
            log.warning("Input text is nil.")
            return
        }
        
        viewModel?.didEnterTextField(inputText)
    }
}

// MARK: - private method

private extension QiitaUserSearchViewController {
    
    // MARK: state update method
    
    func addObserveViewState(_ stateStream: AsyncStream<QiitaUserSearchViewModel.ViewState>) {
        
        Task {
            
            for await state in stateStream {
                
                log.debug("state: \(state)")
                
                switch state {
                    
                case .initial(let state), .appeared(let state):
                    removeProgressIndicator()
                    updateViewWithState(state)
                    
                case .loading:
                    showProgressIndicator()
                    
                case .screenTransition(let user):
                    transitionToUserDetailScene(with: user)
                    
                case .alert(let alert):
                    alert.showAlert(target: self) { [weak self] in
                        
                        self?.viewModel?.tappedCloseAlertButton()
                    }
                }
            }
        }
    }
    
    func updateViewWithState(_ state: QiitaUserSearchViewModel.ViewStateEntity) {
        
        searchButton.isEnabled = state.isEnabledSearchButton
        wordList = state.postSearchTextList
        wordListTableView.reloadData()
    }
    
    func showProgressIndicator() {
        
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
    }
    
    func removeProgressIndicator() {
        
        guard let progressIndicator else { return }
        progressIndicator.removeFromSuperview()
    }
    
    func transitionToUserDetailScene(with user: QiitaUserModel) {
        
        log.info("user: \(user)")
        removeProgressIndicator()
        navigationController?.pushViewController(QiitaUserDetailViewController.getInstance(user: user), animated: true)
    }
    
    // MARK: view setup method
    
    func setupNavigationBar() {
        
        // ナビゲーションバーを非表示にする
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func setupBackgroundView() {
        
        view.backgroundColor = .primaryBackgroundColor
    }
    
    func setupTableView() {
        
        wordListTableView.delegate = self
        wordListTableView.dataSource = self
        wordListTableView.backgroundColor = .primaryBackgroundColor
        wordListTableView.sectionIndexBackgroundColor = .primaryBackgroundColor
        wordListTableView.separatorInset = .zero
        wordListTableView.tableFooterView = UIView()
    }
    
    func setupSearchUserTextFiled() {
        
        searchUserTextField.delegate = self
        searchUserTextField.placeholder = "ユーザーIDで検索することができます"
        searchUserTextField.font = .projectFont(.small)
        searchUserTextField.borderStyle = .roundedRect
        searchUserTextField.layer.cornerRadius = 8
    }
    
    func setupSearchButton() {
        
        searchButton.addTarget(self, action: #selector(tappedSearchButton), for: .touchUpInside)
        searchButton.style()
        var config = searchButton.configuration
        let titleContainer = AttributeContainer([.font: UIFont.projectFont(.medium)])
        config?.attributedTitle = AttributedString("検索", attributes: titleContainer)
        searchButton.configuration = config
        searchButton.updateConfiguration()
    }
    
    // MARK: other method
    
    @objc func tappedSearchButton() {
        
        Task {
            
            await viewModel?.tappedSearchButton()
        }
    }
}
