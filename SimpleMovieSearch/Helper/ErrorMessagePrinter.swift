//
//  ErrorMessagePrinter.swift
//  SimpleMovieSearch
//
//  Created by Jinyoung Kim on 2022/12/22.
//

import Foundation

final class ErrorMessagePrinter {
    private init() { }
    
    static func print(error: Error, file: String = #fileID, line: Int = #line) {
        Swift.print("❗️ 에러 발생: ", error, "에러 설명: ", String(reflecting: error))
        Swift.print("📍 위치: ", file, "line: ", line)
    }
    
    static func print(errorDescription: String, file: String = #fileID, line: Int = #line) {
        Swift.print("❗️ 에러 발생: ", errorDescription)
        Swift.print("📍 위치: ", file, "line: ", line)
    }
}
