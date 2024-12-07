//
//  ContainerFactory.swift
//  QiitaWatch
//
//  Created by 佐藤汰一 on 2024/11/14.
//

import SwiftData

struct ContainerFactory {
    
    static let modelsType: [any PersistentModel.Type] = [SearchWordModel.self]
    
    // モデルコンテナを初期化する
    static func initialize() -> ModelContainer {
        
        // スキーマの定義
        let schema = Schema(modelsType)
        // モデルコンテナの構成を設定
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            // モデルコンテナを設定して返す
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            // エラーが発生した場合は致命的なエラーを発生させる
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
}
