//
//  ApiService.swift
//  QiitaWatch
//
//  Created by 佐藤汰一 on 2024/11/14.
//

import Alamofire
import Foundation

struct ApiService: Equatable {
    
    let baseUrl: URL
    let parameters: [String: String]
    
    init(url: URL, parameters: [String: String] = [:]) {
        
        self.baseUrl = url
        self.parameters = parameters
    }
}
