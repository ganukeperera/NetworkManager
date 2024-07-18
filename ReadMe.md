# ``NetworkManager``

NetworkManager is a robust and efficient networking library designed for Swift applications. It simplifies the process of making HTTP requests and handling responses, making it easy to interact with RESTful APIs. This package provides a streamlined, async/await-based API for modern Swift concurrency, ensuring your network operations are both efficient and easy to manage.

### Key Features:

* Asynchronous Requests: Utilizes Swift's async/await syntax for clear and concise asynchronous code.

* Error Handling: Comprehensive error handling for various network-related issues, including connectivity, invalid responses, and data decoding errors.

* Decodable Support: Automatically decodes JSON responses into your custom Decodable types.

* Customizable Endpoints: Easily configure HTTP methods, base URLs, paths, and query parameters for your API endpoints.

* Singleton Access: Provides a shared singleton instance for easy access throughout your application.


### Installation

To Install this package, import `https://github.com/ganukeperera/NetworkManager` in SPM.

### Usage example

```swift
    /// Define the response type
    private struct User: Codable {
        let firstName: String
        let lastName: String
    }
    
    /// Define the endpoint
    private struct UserEndPoint: Endpoint {
        var scheme: String {
            "https"
        }
        var method: String {
            "GET"
        }
        var baseURL: String {
            "www.example.com"
        }
        var path: String {
            "/user"
        }
        var queryParams: [URLQueryItem] {
            []
        }
        var body: NetworkManager.RequestBody? {
            nil
        }
    }

    /// Load Data using endpoint
    func loadData() {
        Task {
            do {
                let result = try await NetworkManager.shared.request(endpoint: UserEndPoint(), for: User.self)
                
            } catch {
                ///Error Handling
                if let error = error as? NetworkError {
                    switch error {
                    case .connectivity:
                        print("Connectivity error")
                    case .invalidData:
                        print("Invalid Data")
                    case .invalidResponse:
                        print("Invalid Response")
                    case let .invalidURL(endpoint):
                        print("Invalid URL")
                    }
                }
            }
        }
    }

```

