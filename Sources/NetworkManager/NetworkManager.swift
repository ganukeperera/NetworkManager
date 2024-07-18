//
//  NetworkManager.swift
//  NetworkLayer
//
//  Created by Ganuke Perera on 2024-07-09.
//

import Foundation

public enum NetworkError: Error {
    case invalidURL(Endpoint)
    case connectivity
    case invalidResponse
    case invalidData
}

public final class NetworkManager {
    
    public static let shared = NetworkManager()
    private let session: URLSession
    
    init(_ session: URLSession = .shared) {
        self.session = session
    }
    
    public func request<T: Decodable>(endpoint: Endpoint, for: T.Type) async throws -> T {
        let request = try getRequest(endpoint)
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (0...299).contains(httpResponse.statusCode) else {
                throw NetworkError.invalidResponse
            }
            let jsonData = try JSONDecoder().decode(T.self, from: data)
            return jsonData
        } catch {
            try handleError(error)
            throw error
        }
    }
    
    //MARK: Helpers
    private func getRequest(_ endpoint: Endpoint) throws -> URLRequest {
        guard let url = urlComponents(for: endpoint).url else {
            throw NetworkError.invalidURL(endpoint)
        }
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method
        
        switch endpoint.body {
        case let .data(data):
            request.httpBody = data
        case let .dictionary(dict):
            let jsonData = try? JSONSerialization.data(withJSONObject: dict)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData
        default:
            break
        }

        return request
    }
    
    private func urlComponents(for endpoint: Endpoint) -> URLComponents {
        var urlComponent = URLComponents()
        urlComponent.scheme = endpoint.scheme
        urlComponent.host = endpoint.baseURL
        urlComponent.path = endpoint.path
        urlComponent.queryItems = endpoint.queryParams
        return urlComponent
    }
    
    private func handleError(_ error: Error) throws {
        switch error {
        case is DecodingError:
            throw NetworkError.invalidResponse
        default:
            throw NetworkError.connectivity
        }
    }
}

