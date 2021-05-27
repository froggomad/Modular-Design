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
        
        XCTAssertEqual(client.requestedURLs.count, 0)
    }
    
    func test_load_requestsDataFromURL() {
        let url = URL(string: "https://www.google.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load()
        sut.load()
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        
        var capturedErrors = [RemoteFeedLoader.Error]()
        sut.load() { capturedErrors.append($0) }
        
        let clientError = NSError(domain: "Test", code: 0)
        // call first completion with clientError
        client.complete(with: clientError)
        
        XCTAssertEqual(capturedErrors, [.connectivity])
    }
    
    // MARK: - Helpers -
    
    private func makeSUT(url: URL = URL(string: "https://www.google.com")!) -> (sut: RemoteFeedLoader, client: MockHTTPClient) {
        let client = MockHTTPClient()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }

    private class MockHTTPClient: HTTPClient {
        var requestedURLs = [URL]()
        var completions = [(Error) -> Void]()
        
        func complete(with error: Error, index: Int = 0) {
            completions[index](error)
        }
        
        func get(from url: URL, completion: @escaping (Error) -> Void) {
            completions.append(completion)
            requestedURLs.append(url)
        }
        
    }
}
