//
//  QiitaArticleViewController.swift
//  QiitaWatch
//
//  Created by 佐藤汰一 on 2024/11/19.
//

import SafariServices
import UIKit

/// 記事表示画面
///
/// # 仕様
/// - ユーザー詳細画面で取得した記事のリストから選択された記事を表示する
///   - iOS なら SFSafariViewController, Android なら CustomTabs を利用する
final class QiitaArticleViewController: SFSafariViewController {
    
    // MARK: - factory method
    
    static func getInstance(_ articleUrl: URL) -> UIViewController {
        
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = false
        config.barCollapsingEnabled = true
        
        let viewController = QiitaArticleViewController(url: articleUrl, configuration: config)
        viewController.dismissButtonStyle = .close
        return viewController
    }
    
    // MARK: - lifecycle method

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.delegate = self
        setupNavigationBar()
    }
}

// MARK: - SFSafariViewControllerDelegate method

extension QiitaArticleViewController: @preconcurrency SFSafariViewControllerDelegate {
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        
        log.debug("[In]")
        navigationController?.popViewController(animated: true)
    }
    
    func safariViewController(_ controller: SFSafariViewController, didCompleteInitialLoad didLoadSuccessfully: Bool) {
        
        log.debug("[In] didCompleteInitialLoad: \(didLoadSuccessfully)")
        if !didLoadSuccessfully {
            
            navigationController?.popViewController(animated: true)
        }
    }
}

// MARK: - private method

private extension QiitaArticleViewController {
    
    // MARK: view setup method
    
    func setupNavigationBar() {
        
        // ナビゲーションバーを表示にする
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
}
