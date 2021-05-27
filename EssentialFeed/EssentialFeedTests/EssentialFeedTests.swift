//
//  EssentialFeedTests.swift
//  EssentialFeedTests
//
//  Created by Kenneth Dubroff on 5/24/21.
//

import XCTest
import EssentialFeed

class EssentialFeedTests: XCTestCase {
    

    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestsDataFromURL() {
        let url = URL(string: "https://www.google.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load()
        sut.load()
        
        XCTAssertEqual(url, client.requestedURL)
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        client.error = NSError(domain: "Test", code: 0)
        
        var capturedError: RemoteFeedLoader.Error?
        sut.load { error in capturedError = error }
        XCTAssertEqual(capturedError, .connectivity)
    }
    
    // MARK: - Helpers -
    
    private func makeSUT(url: URL = URL(string: "https://www.google.com")!) -> (sut: RemoteFeedLoader, client: MockHTTPClient) {
        let client = MockHTTPClient()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }

    private class MockHTTPClient: HTTPClient {
        var requestedURL: URL?
        var requestedURLs = [URL]()
        var error: Error?
        
        func get(from url: URL, completion: @escaping (Error) -> Void) {
            
            if let error = error {
                completion(error)
            }
            
            requestedURL = url
            requestedURLs.append(url)
        }
        
    }
}
