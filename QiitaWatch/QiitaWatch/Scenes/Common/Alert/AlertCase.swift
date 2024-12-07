//
//  AlertCase.swift
//  QiitaWatch
//
//  Created by 佐藤汰一 on 2024/11/14.
//

import Foundation

@MainActor
enum AlertCase: Equatable {
        
    case noHitQiitaUser // ユーザ取得が0件だった場合のアラート
    case networkError // 通信エラーの場合のアラート
    case networkErrorWithRetry // 通信エラーの場合のアラート(リトライ付き)
    case unexpectedError // 想定外のエラーの場合のアラート
}

// MARK: - alert contents definition

extension AlertCase {
    
    var title: String {
        
        switch self {
            
        case .noHitQiitaUser:
            return "ユーザーが取得できませんでした。"
            
        case .networkError, .networkErrorWithRetry:
            return "通信に失敗しました。"
            + "\n"
            + "通信環境の良い場所で再度お試しください。"
            
        case .unexpectedError:
            return "想定外のエラーが発生しました。"
        }
    }
    
    var firstButtonTitle: String {
        
        switch self {
            
        case .noHitQiitaUser, .networkError, .networkErrorWithRetry, .unexpectedError:
            return "閉じる"
        }
    }
    
    var secondButtonTitle: String? {
        
        switch self {
            
        case .networkErrorWithRetry:
            return "リトライ"
            
        case .noHitQiitaUser, .networkError, .unexpectedError:
            return nil
        }
    }
    
    var handlerType: HandlerType {
        
        switch self {
            
        case .noHitQiitaUser,
                .networkError,
                .unexpectedError:
            return .only
            
        case .networkErrorWithRetry:
            return .double
        }
    }
    
    func getExecutorInstance() -> AlertExecutor {
        
        return AlertExecutor(alertCase: self)
    }
}

extension AlertCase {
    
    enum HandlerType {
        
        /// ボタンが一つのアラート
        case only
        /// ボタンが二つのアラート
        case double
    }
}
