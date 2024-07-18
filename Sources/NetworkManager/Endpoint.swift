//
//  Endpoint.swift
//  NetworkLayer
//
//  Created by Ganuke Perera on 2024-07-09.
//

import Foundation

public protocol Endpoint {
    var scheme: String { get }
    var method: String { get }
    var baseURL: String { get }
    var path: String { get }
    var queryParams: [URLQueryItem] { get }
    var body: RequestBody? { get }
}

public enum RequestBody {
    case data(Data)
    case dictionary(Dictionary<String,Any>)
}

