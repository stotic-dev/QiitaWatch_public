//
//  QiitaCommonUrlParameter.swift
//  QiitaWatch
//
//  Created by 佐藤汰一 on 2024/11/20.
//

struct QiitaCommonUrlParamBuilder {
    
    // 一ページあたりの記事数
    static private let pagePerCount = "10"
    // ページ指定のkey
    static private let pageParameterKey = "page"
    // 一ページあたりの記事数指定のkey
    static private let pagePerCountParameterKey = "per_page"
    
    /// ページ数指定の共通パラメータ生成
    static func build(page: Int) -> [String: String] {
        
        return [
            pageParameterKey: String(page),
            pagePerCountParameterKey: pagePerCount
        ]
    }
}
