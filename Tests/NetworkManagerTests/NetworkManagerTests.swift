import XCTest
@testable import NetworkManager

final class NetworkManagerTests: XCTestCase {
    override func setUp() {
        super.setUp()
        URLProtocolStub.registerForIntercepting()
    }
    
    override func tearDown() {
        super.tearDown()
        URLProtocolStub.unregisterForIntercepting()
    }
    
    func testCreationOfNetworkMangerDoesNotMakeAnyRequests() {
        let expectation = expectation(description: "waiting for test get called")
        URLProtocolStub.observeRequest { request in
            XCTFail("Does not expect to get called on Network Manager creation")
        }
        
        let _ = makeSUT()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.5)
    }
    
    func testRequestFailWithInvalidURLWithInvalidEndpoint() async {
        //GIVEN
        let sut = makeSUT()
        
        do {
            //WHEN
            let _ = try await sut.request(endpoint: Endpoints.invalidURL, for: UserDetails.self)
            XCTFail("Should fail with a error")
        } catch {
            //THEN
            guard case NetworkError.invalidURL = error else {
                XCTFail("Should fail with a invalidURL error, but failed with error = \(error.localizedDescription)")
                return
            }
        }
    }
    
    func testRequestWithGETMakeGETRequest() async throws {
        // GIVEN
        let sut = makeSUT()
        let expectation = XCTestExpectation(description: "Observer called")
        URLProtocolStub.stub(response: anyHTTPURLResponse(), data: anyData(), error: nil)
        
        URLProtocolStub.observeRequest { [self] request in
            // THEN
            XCTAssertEqual(request.httpMethod, "GET")
            XCTAssertEqual(request.url, urlComponents(for: Endpoints.getURL).url)
            expectation.fulfill() // Fulfill the expectation once the assertion is done
        }
        
        // WHEN
        let _ = try await sut.request(endpoint: Endpoints.getURL, for: UserDetails.self)
        await fulfillment(of: [expectation], timeout: 1.0)
    }
    
    func testRequestWithPOSTMakePOSTRequest() async throws {
        // GIVEN
        let sut = makeSUT()
        let expectation = XCTestExpectation(description: "Observer called")
        URLProtocolStub.stub(response: anyHTTPURLResponse(), data: anyData(), error: nil)
        
        URLProtocolStub.observeRequest { [self] request in
            // THEN
            XCTAssertEqual(request.httpMethod, "POST")
            XCTAssertEqual(request.url, urlComponents(for: Endpoints.postURL).url)
            expectation.fulfill() // Fulfill the expectation once the assertion is done
        }
        
        // WHEN
        let _ = try await sut.request(endpoint: Endpoints.postURL, for: UserDetails.self)
        await fulfillment(of: [expectation], timeout: 1.0)
    }
    
    func testRequestFailOnInvalidRepresentations() async throws {
        let _ = await resultErrorFor(response: nonHTTPURLResponse(), data: anyData(), error: nil)
        let _ = await resultErrorFor(response: anyHTTPURLResponse(with: 500), data: anyData(), error: nil)
        let _ = await resultErrorFor(response: anyHTTPURLResponse(), data: anyData(), error: anyError())
    }
    
    func testRequestSuccessWithHTTPURLResponseAndData() async throws {
        let sut = makeSUT()
        URLProtocolStub.stub(response: anyHTTPURLResponse(), data: anyData(), error: nil)
        
        let result = try await sut.request(endpoint: Endpoints.getURL, for: UserDetails.self)
        
        XCTAssertEqual(result.userID, 234)
        XCTAssertEqual(result.fullName, "james")
    }
    
    
    //MARK: Helpers
    private func makeSUT() -> NetworkManager {
        NetworkManager.shared
    }
    
    func resultErrorFor(response: URLResponse?, data: Data?, error: Error?, file: StaticString = #filePath, line: UInt = #line) async {
        let sut = makeSUT()
        URLProtocolStub.stub(response: response, data: data, error: error)
        
        do {
            let _ = try await sut.request(endpoint: Endpoints.getURL, for: UserDetails.self)
        } catch {
            return
        }
        XCTFail("Expected to fail with error", file: file, line: line)
    }
    
    private func anyHTTPURLResponse(with statusCode: Int = 200) -> HTTPURLResponse {
        HTTPURLResponse(url: anyURL(), statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }
    
    private func nonHTTPURLResponse() -> URLResponse {
        URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
    
    private func anyURL() -> URL {
        URL(string: "https://a-given-url.com")!
    }
    
    private func anyData() -> Data {
        Data("{\"userID\" : 234,\"fullName\":\"james\" }".utf8)
    }
    
    private func anyError() -> NSError {
        NSError(domain: "com.ganuke", code: 123)
    }
    
    private struct UserDetails: Decodable {
        let userID: Int
        let fullName: String
    }
    
    private func urlComponents(for endpoint: Endpoint) -> URLComponents {
        var urlComponent = URLComponents()
        urlComponent.scheme = endpoint.scheme
        urlComponent.host = endpoint.baseURL
        urlComponent.path = endpoint.path
        urlComponent.queryItems = endpoint.queryParams
        return urlComponent
    }
}
