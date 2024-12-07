//
//  TestContainerFactory.swift
//  QiitaWatchTests
//
//  Created by 佐藤汰一 on 2024/11/14.
//

import SwiftData

@testable import QiitaWatch

struct TestContainerFactory {
        
    // モデルコンテナを初期化する
    static func initialize() -> ModelContainer {
        
        // スキーマの定義
        let schema = Schema(ContainerFactory.modelsType)
        // モデルコンテナの構成を設定
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        
        do {
            // モデルコンテナを設定して返す
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            // エラーが発生した場合は致命的なエラーを発生させる
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
}
