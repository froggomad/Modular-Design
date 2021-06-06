//
//  EssentialFeedTests.swift
//  EssentialFeedTests
//
//  Created by Kenneth Dubroff on 5/24/21.
//

import XCTest
import EssentialFeed

class RemoteFeedLoadUseCaseTests: XCTestCase {
    
    
    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        
        XCTAssertEqual(client.requestedURLs.count, 0)
    }
    
    func test_load_requestsDataFromURL() {
        let url = URL(string: "https://www.google.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load { _ in }
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: failure(.connectivity) ) {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        }
        
    }
    
    func test_load_deliversHTTPResponseError() {
        let (sut, client) = makeSUT()
        
        // we're expecting 200 for success
        let failureCodes = [199, 201, 300, 400, 500]
            .enumerated()
        
        failureCodes.forEach { (index, code) in
            let json = makeItemsJSON([])
            
            expect(sut, toCompleteWith: failure( .invalidData) ) {
                client.complete(withStatusCode: code, data: json,
                                at: index)
            }
            
        }
    }
    
    func test_load_deliversInvalidJsonErrorOnSuccessCase() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: failure(.invalidData), when: {
            let invalidJSON = Data("{".utf8)
            client.complete(withStatusCode: 200, data: invalidJSON)
        })
        
    }
    
    func test_load_deliversEmptyArrayOn200HTTPResponseWithEmptyJSONList() {
        
        let (sut, client) = makeSUT()
        expect(sut, toCompleteWith: .success([]), when: {
            let emptyJSONList = makeItemsJSON([])
            
            client.complete(withStatusCode: 200, data: emptyJSONList)
        })
    }
    
    func test_load_deliverItemsOn200HTTPResponseWithJSONItem() {
        let (sut, client) = makeSUT()
        
        let item1 = makeItem(
            id: UUID(),
            description: nil,
            location: "item1",
            imageURL: URL(string: "https://www.google.com")!
        )
        
        let item2 = makeItem(
            id: UUID(),
            description: "item2",
            location: nil,
            imageURL: URL(string: "https://www.google.com")!
        )
        
        let jsonData = makeItemsJSON([item1.json, item2.json])
        
        expect(sut, toCompleteWith: .success([item1.model, item2.model]), when: {
            
            client.complete(withStatusCode: 200, data:  jsonData)
        })
    }
    
    func test_load_doesNotDeliverResultAfterInstanceDeallocated() {
        let url = URL(string: "https://www.google.com")!
        let client = MockHTTPClient()
        var sut: RemoteFeedLoader? = RemoteFeedLoader(url: url, client: client)
        
        var capturedResults = [RemoteFeedLoader.Result]()
        sut?.load { capturedResults.append($0) }
        
        sut = nil
        client.complete(withStatusCode: 200, data: makeItemsJSON([]))
        
        XCTAssertTrue(capturedResults.isEmpty)
    }
    
    // MARK: - Helpers -
    
    private func makeSUT(url: URL = URL(string: "https://www.google.com")!, file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteFeedLoader, client: MockHTTPClient) {
        let client = MockHTTPClient()
        let sut = RemoteFeedLoader(url: url, client: client)
        assertNoMemoryLeak(client, file: file, line: line)
        assertNoMemoryLeak(sut, file: file, line: line)
        return (sut, client)
    }
    
    private func failure(_ error: RemoteFeedLoader.Error) -> RemoteFeedLoader.Result {
        return .failure(error)
    }
    
    private func makeItem(id: UUID, description: String? = nil, location: String? = nil, imageURL: URL) -> (model: FeedItem, json: [String: Any]) {
        let item = FeedItem(id: id, description: description, location: location, imageURL: imageURL)
        let json: [String: Any] = [
            "id": id.uuidString,
            "description": description as Any,
            "location": location as Any,
            "image": imageURL.absoluteString
        ].compactMapValues({ $0 })
        
        return (model: item, json: json)
    }
    
    private func makeItemsJSON(_ items: [[String: Any]]) -> Data {
        let json = ["items": items]
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
    private func expect(_ sut: RemoteFeedLoader, toCompleteWith expectedResult: RemoteFeedLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        
        let expectation = expectation(description: "Wait for sut.load")
        
        sut.load { receivedResult in
            // (receivedResult, expectedResult) uses pattern matching
            switch (receivedResult, expectedResult) {
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
                
            case let (.failure(receivedError as RemoteFeedLoader.Error), .failure(expectedError as RemoteFeedLoader.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
                
            default:
                XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
            }
            expectation.fulfill()
        }
        action()
        
        wait(for: [expectation], timeout: 0.1)
        
        
    }
    
    private class MockHTTPClient: HTTPClient {
        private var messages = [(url: URL, completion: (HTTPClientResult) -> Void)]()
        
        var requestedURLs: [URL] {
            return messages.map { $0.url }
        }
        
        func get(from url: URL, completion: @escaping(HTTPClientResult) -> Void = { _ in }) {
            messages.append((url, completion))            
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion( .failure(error) )
        }
        
        func complete(withStatusCode code: Int, data: Data = Data(), at index: Int = 0) {
            print(index)
            let response = HTTPURLResponse(
                url: requestedURLs[index],
                statusCode: code,
                httpVersion: nil,
                headerFields: nil
            )!
            messages[index].completion(.success(data, response))
        }
        
    }
}
