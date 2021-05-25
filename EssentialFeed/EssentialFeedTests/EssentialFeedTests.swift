//
//  EssentialFeedTests.swift
//  EssentialFeedTests
//
//  Created by Kenneth Dubroff on 5/24/21.
//

import XCTest

class RemoteFeedLoader {
    let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func load() {
        client.get(from: URL(string: "https://www.google.com")!)
    }
}

protocol HTTPClient {
    func get(from url: URL)
}

class MockHTTPClient: HTTPClient {
    func get(from url: URL) {
        requestedURL = url
    }
    
    var requestedURL: URL?
}

class EssentialFeedTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let client = MockHTTPClient()
        _ = RemoteFeedLoader(client: client)
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestDataFromURL() {
        let client = MockHTTPClient()
        let sut = RemoteFeedLoader(client: client)
        
        sut.load()
        
        XCTAssertNotNil(client.requestedURL)
    }

}
