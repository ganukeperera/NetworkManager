//
//  URLProtocolStubs.swift
//  NetworkLayerTests
//
//  Created by Ganuke Perera on 2024-07-11.
//

import Foundation

class URLProtocolStub: URLProtocol {
    
    private struct Stub {
        let response: URLResponse?
        let data: Data?
        let error: Error?
    }
    
    private static var stub: Stub?
    private static var observer: ((URLRequest) -> Void)?
    
    static func registerForIntercepting() {
        URLProtocol.registerClass(URLProtocolStub.self)
    }
    
    static func unregisterForIntercepting() {
        URLProtocol.unregisterClass(URLProtocolStub.self)
        stub = nil
        observer = nil
    }
    
    static func stub(response: URLResponse?, data: Data?, error: Error?) {
        stub = Stub(response: response, data: data, error: error)
    }
    
    static func observeRequest(observer: @escaping (URLRequest) -> Void) {
        URLProtocolStub.observer = observer
    }
    
    ///URLProtocol Related Methods
    override class func canInit(with request: URLRequest) -> Bool {
        true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }
    
    override func startLoading() {
        if let observer = URLProtocolStub.observer {
            observer(request)
        }
        
        if let error = URLProtocolStub.stub?.error {
            client?.urlProtocol(self, didFailWithError: error)
        }
        if let data = URLProtocolStub.stub?.data {
            client?.urlProtocol(self, didLoad: data)
        }
        
        if let response = URLProtocolStub.stub?.response {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }
        
        client?.urlProtocolDidFinishLoading(self)
        
    }
    
    override func stopLoading() {}
}
