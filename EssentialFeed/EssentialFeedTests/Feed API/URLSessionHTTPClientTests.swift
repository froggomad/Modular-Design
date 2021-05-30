//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Kenneth Dubroff on 5/29/21.
//

import XCTest
import EssentialFeed

class URLSessionHTTPClient {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    /// error for invalid scenarios
    struct UnexpectedValueRepresentation: Error {}
    
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        session.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data,
                      data.count > 0,
                      let response = response as? HTTPURLResponse {
                completion(.success(data, response as! HTTPURLResponse))
            } else {
                completion(.failure(UnexpectedValueRepresentation()))
            }
        }.resume()
    }
}

class URLSessionHTTPClientTests: XCTestCase {
    override func setUp() {
        super.setUp()
        URLProtocolStub.startInterceptingRequests()
    }
    
    override func tearDown() {
        super.tearDown()
        URLProtocolStub.stopInterceptingRequests()
    }
    
    func test_getFromURL_performsGetRequestWithURL() {
        let expectation = XCTestExpectation(description: "wait for \(#function)")
        
        URLProtocolStub.observeRequests { request in
            XCTAssertEqual(request.url, self.anyURL)
            XCTAssertEqual(request.httpMethod, "GET")
            expectation.fulfill()
        }
        
        makeSUT().get(from: anyURL) { _ in }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_getFromURL_failsForInvalidCases() {
        
        
        XCTAssertNotNil(resultError(for:nil,
                                    response:nil,
                                    error:nil))
        
        XCTAssertNotNil(resultError(for:nil,
                                    response: nonHTTPURLResponse,
                                    error:nil))
        
        XCTAssertNotNil(resultError(for:nil,
                                    response: anyHTTPURLResponse,
                                    error:nil))
        
        XCTAssertNotNil(resultError(for:anyData,
                                    response: nil,
                                    error:nil))
        
        XCTAssertNotNil(resultError(for:anyData,
                                    response: nil,
                                    error:anyError))
        
        XCTAssertNotNil(resultError(for:nil,
                                    response: nonHTTPURLResponse,
                                    error:anyError))
        
        XCTAssertNotNil(resultError(for:nil,
                                    response: anyHTTPURLResponse,
                                    error:anyError))
        
        XCTAssertNotNil(resultError(for:anyData,
                                    response: nonHTTPURLResponse,
                                    error:anyError))
        
        XCTAssertNotNil(resultError(for:anyData,
                                    response: anyHTTPURLResponse,
                                    error: anyError))
        
        XCTAssertNotNil(resultError(for:anyData,
                                    response: nonHTTPURLResponse,
                                    error: nil))
        
    }
    
    func test_getFromURL_succeedsOnHTTPURLResponseWithData() {
        let data = anyData
        let response = anyHTTPURLResponse
        URLProtocolStub.stub(data: data, response: response, error: nil)
        
        let expectation = XCTestExpectation(description: "wait for \(#function)")
        makeSUT().get(from: anyURL) { result in
            switch result {
            case let .success(receivedData, receivedResponse):
                XCTAssertEqual(receivedData, data)
                XCTAssertEqual(receivedResponse.statusCode, response.statusCode)
            default:
                XCTFail("Expected success, got \(result)")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1)
    }
    
    func test_getFromURL_failsOnError() {
        let requestError = anyError
        let receivedError = resultError(for: nil, response: nil, error: requestError) as NSError?
        
        XCTAssertEqual(receivedError?.domain, requestError.domain)
        XCTAssertEqual(receivedError?.code, requestError.code)
        
    }
    
    // MARK: - Helpers -
    private lazy var nonHTTPURLResponse: URLResponse = {
        URLResponse(url: anyURL,
                    mimeType: nil,
                    expectedContentLength: 0,
                    textEncodingName: nil)
    }()
    
    private lazy var anyHTTPURLResponse: HTTPURLResponse = {
        HTTPURLResponse(url: anyURL,
                        statusCode: 200,
                        httpVersion: nil,
                        headerFields: nil)!
    }()
    
    private var anyData: Data {
        Data("any data".utf8)
    }
    
    private var anyError: NSError {
        NSError(domain: "any error", code: 0)
    }
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> URLSessionHTTPClient {
        let sut = URLSessionHTTPClient()
        assertNoMemoryLeak(sut, file: file, line: line)
        return sut
    }
    
    private func resultError(for data: Data?, response: URLResponse?, error: Error?, file: StaticString = #file, line: UInt = #line) -> Error? {
        URLProtocolStub.stub(data: data, response: response, error: error)
        
        let sut = makeSUT(file: file, line: line)
        let expectation = XCTestExpectation(description: "Wait for \(#function)")
        
        var receivedError: Error?
        sut.get(from: anyURL) { result in
            switch result {
            case let .failure(error):
                receivedError = error
            default:
                XCTFail("Expected failure with error, got \(result) instead", file: file, line: line)
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
        return receivedError
    }
    
    private var anyURL: URL {
        return URL(string: "https://www.google.com")!
    }
    
    #warning("URLProtocol is an abstract class, <not> protocol")
    private class URLProtocolStub: URLProtocol {
        private static var stub: Stub?
        private static var requestObserver: ((URLRequest) -> Void)?
        
        private struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
        }
        
        static func stub(data: Data?, response: URLResponse?, error: Error?) {
            stub = Stub(data: data, response: response, error: error)
        }
        
        static func observeRequests(observer: @escaping (URLRequest) -> Void) {
            requestObserver = observer
        }
        
        static func startInterceptingRequests() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptingRequests() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stub = nil
            requestObserver = nil
        }
        
        // MARK: - URLProtocol class conformance -
        override class func canInit(with request: URLRequest) -> Bool {
            requestObserver?(request)
            return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            let stub = URLProtocolStub.stub
            
            if let data = stub?.data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let response = stub?.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            if let error = stub?.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {}
        
    }
    
}
