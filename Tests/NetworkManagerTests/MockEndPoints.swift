//
//  MockEndPoints.swift
//  NetworkLayerTests
//
//  Created by Ganuke Perera on 2024-07-11.
//

import Foundation
@testable import NetworkManager

enum Endpoints: Endpoint {
    case invalidURL
    case getURL
    case postURL
    
    var scheme: String {
        "https"
    }
    
    var method: String{
        switch self {
        case .postURL:
            return "POST"
        case .getURL:
            return "GET"
        default:
            return "GET"
        }
    }
    
    var baseURL: String {
        "www.example.com"
    }
    
    var path: String {
        switch self {
        case .invalidURL:
            return "invalidPath"
        case .getURL:
            return "/validGetPath"
        case .postURL:
            return "/validPostPath"
        }
    }
    
    var queryParams: [URLQueryItem] {
        let query = URLQueryItem(name: "query", value: "123")
        return [query]
    }
    
    var body: RequestBody? {
        switch self {
        case .postURL:
            return .dictionary(["username":"tomhank"])
        default:
            return nil
        }
    }
}
