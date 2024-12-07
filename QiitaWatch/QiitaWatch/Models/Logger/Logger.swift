//
//  Logger.swift
//  QiitaWatch
//
//  Created by 佐藤汰一 on 2024/11/14.
//

import OSLog

let log = AppLogger()

struct AppLogger {
    
    let log = Logger(subsystem: "QiitaWatch", category: "app")
    
    func debug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        
        log.debug("🟦 \(getCommonText(file: file, function: function, line: line)) \(message)")
    }
    
    func trace(file: String = #file, function: String = #function, line: Int = #line) {
        log.trace("🟪 \(getCommonText(file: file, function: function, line: line))")
    }
    
    func info(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        
        log.info("🟩 \(getCommonText(file: file, function: function, line: line)) \(message)")
    }
    
    func warning(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        
        log.warning("🟨 \(getCommonText(file: file, function: function, line: line)) \(message)")
    }
    
    func error(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        
        log.error("🟥 \(getCommonText(file: file, function: function, line: line)) \(message)")
    }
}

private extension AppLogger {
    
    func getCommonText(file: String, function: String, line: Int) -> String {
        
        return "[\(getFileName(file)):\(function):\(line)]"
    }
    
    func getFileName(_ filePath: String) -> String {
        
        return filePath.components(separatedBy: "/").last ?? ""
    }
}
