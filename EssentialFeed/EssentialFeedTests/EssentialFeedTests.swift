//
//  EssentialFeedTests.swift
//  EssentialFeedTests
//
//  Created by Kenneth Dubroff on 5/24/21.
//

import XCTest

class RemoteFeedLoader {
    func load() {
        HTTPClient.shared.requestedURL = URL(string: "https://www.google.com")
    }
}

class HTTPClient {
    static let shared = HTTPClient()
    private init() { }
    var requestedURL: URL?
}

class EssentialFeedTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let client = HTTPClient.shared
        _ = RemoteFeedLoader()
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestDataFromURL() {
        let client = HTTPClient.shared
        let sut = RemoteFeedLoader()
        
        sut.load()
        
        XCTAssertNotNil(client.requestedURL)
    }

}
