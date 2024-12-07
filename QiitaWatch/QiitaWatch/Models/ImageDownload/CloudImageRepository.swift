//
//  CloudImageRepository.swift
//  QiitaWatch
//
//  Created by 佐藤汰一 on 2024/11/16.
//

import Foundation

protocol CloudImageRepository: Sendable {
    
    /// URLから画像データを取得する
    func download(_ url: URL) async throws -> Data?
}
