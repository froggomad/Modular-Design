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
                      let response = response as? HTTPURLResponse {
                completion(.success(data, response))
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
        
        //        XCTAssertNotNil(resultError(for:nil,
        //                                    response: anyHTTPURLResponse,
        //                                    error:nil))
        
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
        
        let receivedValues = resultValues(for: data, response: response, error: nil)
        
        XCTAssertEqual(receivedValues?.data, data)
        XCTAssertEqual(receivedValues?.response.url, response.url)
        XCTAssertEqual(receivedValues?.response.statusCode, response.statusCode)
    }
    // edge case: framework seems to be replacing nil data with 0 bytes
    func test_getFromURL_succeedsWithEmptyDataOnNilData() {
        let response = anyHTTPURLResponse
        
        let receivedValues = resultValues(for: nil, response: response, error: nil)
        
        let emptyData = Data()
        XCTAssertEqual(receivedValues?.data, emptyData)
        XCTAssertEqual(receivedValues?.response.url, response.url)
        XCTAssertEqual(receivedValues?.response.statusCode, response.statusCode)
        
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
    
    private let anyData: Data = Data("any data".utf8)
    
    private let anyError: NSError = NSError(domain: "any error", code: 0)
    
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> URLSessionHTTPClient {
        let sut = URLSessionHTTPClient()
        assertNoMemoryLeak(sut, file: file, line: line)
        return sut
    }
    
    private func resultValues(for data: Data?, response: URLResponse?, error: Error?, file: StaticString = #file, line: UInt = #line) -> (data: Data, response: HTTPURLResponse)? {
        let result = result(for: data, response: response, error: error, file: file, line: line)
        
        switch result {
        case let .success(data, response):
            return (data, response)
        default:
            XCTFail("Expected success, got \(result) instead", file: file, line: line)
            return nil
        }
    }
    
    private func resultError(for data: Data?, response: URLResponse?, error: Error?, file: StaticString = #file, line: UInt = #line) -> Error? {
        
        let result = result(for: data, response: response, error: error, file: file, line: line)
        
        switch result {
        case let .failure(error):
            return error
        default:
            XCTFail("Expected failure with error, got \(result) instead", file: file, line: line)
            return nil
        }
    }
    
    private func result(for data: Data?, response: URLResponse?, error: Error?, file: StaticString = #file, line: UInt = #line) -> HTTPClientResult {
        URLProtocolStub.stub(data: data, response: response, error: error)
        
        let sut = makeSUT(file: file, line: line)
        let expectation = XCTestExpectation(description: "Wait for \(#function)")
        
        var receivedResult: HTTPClientResult!
        sut.get(from: anyURL) { result in
            receivedResult = result
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
        return receivedResult
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
