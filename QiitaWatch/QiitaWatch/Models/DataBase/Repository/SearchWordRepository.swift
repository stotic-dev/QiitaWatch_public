//
//  SearchWordRepository.swift
//  QiitaWatch
//
//  Created by 佐藤汰一 on 2024/11/14.
//

import Foundation
import SwiftData

@MainActor
final class SearchWordRepository {
    
    private let context: ModelContext
    
    init(context: ModelContext) {
        
        self.context = context
    }
    
    /// 保存している検索文字を全て取得する
    /// - Parameter order: 保存日時のソート順。デフォルトは降順
    func fetchAll(order: SortOrder = .reverse) throws -> [SearchWordModel] {
        
        let sortDescriptor = SortDescriptor<SearchWordModel>(\.createdAt, order: order)
        return try context.fetch(FetchDescriptor<SearchWordModel>(sortBy: [sortDescriptor]))
    }
    
    /// 検索文字を保存もしくは更新する
    /// - Parameter word: 保存する文字
    /// - Description: すでに同じ文字が保存されている場合は作成日時を現在に更新する
    func insertOrUpdate(_ word: String) throws {
        
        if let target = fetchById(word) {
            
            target.createdAt = Date.now.timeIntervalSince1970
            try context.save()
        }
        else {
            
            let model = SearchWordModel(word: word)
            context.insert(model)
        }
    }
    
    /// 保存している検索文字を削除する
    /// - Parameter word: 検索文字
    func delete(_ word: String) {
        
        guard let target = fetchById(word) else { return }
        context.delete(target)
    }
}

private extension SearchWordRepository {
    
    func fetchById(_ word: String) -> SearchWordModel? {
        
        let predicateById = #Predicate<SearchWordModel> { $0.word == word }
        return try? context.fetch(FetchDescriptor<SearchWordModel>(predicate: predicateById)).first
    }
}
