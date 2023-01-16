//
//  OMDBError.swift
//  SimpleMovieSearch
//
//  Created by Jinyoung Kim on 2022/12/25.
//

enum OMDBError {
    static func getErrorDescription(from omdbError: String) -> String? {
        switch omdbError {
        case "Too many results.":
            return "너무 검색결과가 많습니다. 검색어를 좀더 상세히 입력해 주세요."
        default:
            return nil
        }
    }
}
