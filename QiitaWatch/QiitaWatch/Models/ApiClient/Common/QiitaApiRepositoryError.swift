//
//  QiitaApiRepositoryError.swift
//  QiitaWatch
//
//  Created by 佐藤汰一 on 2024/11/20.
//

struct QiitaApiRepositoryError: Error {
    
    /// エラー種別
    private let type: ErrorType
    /// 原因
    let reason: String
    /// 元エラー
    let originalError: Error?
    
    private init(type: ErrorType, reason: String, originalError: Error? = nil) {
        
        self.type = type
        self.reason = reason
        self.originalError = originalError
    }
}

// MARK: - error definition

extension QiitaApiRepositoryError {
    
    /// APIクライアントのエラー
    static func clientError(reason: String, originalError: Error) -> Self {
        
        return QiitaApiRepositoryError(type: .clientError, reason: reason, originalError: originalError)
    }
    /// URL生成のエラー
    static func failedCreateUrlError(url: String) -> Self {
        
        return QiitaApiRepositoryError(type: .failedCreateUrlError,
                                       reason: "Failed create url: \(url)")
    }
    
    /// ユーザーが存在しないエラー
    static let noHitUserError = QiitaApiRepositoryError(type: .noHitUserError,
                                                        reason: "Completed fetch user, But no hit user.")
}

// MARK: - check error property

extension QiitaApiRepositoryError {
    
    var isClientError: Bool {
        
        return type == .clientError
    }
    
    var isFailedCreateUrlError: Bool {
        
        return type == .failedCreateUrlError
    }
    
    var isNoHitUserError: Bool {
        
        return type == .noHitUserError
    }
}

// MARK: - private definiation

private extension QiitaApiRepositoryError {
    
    enum ErrorType {
        
        case clientError
        case failedCreateUrlError
        case noHitUserError
    }
}
