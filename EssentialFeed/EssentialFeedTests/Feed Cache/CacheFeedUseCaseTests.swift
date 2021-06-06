//
//  CacheFeedUseCaseTests.swift
//  EssentialFeed
//
//  Created by Kenneth Dubroff on 6/6/21.
//

import XCTest
import EssentialFeed

class LocalFeedLoader {
    private let store: FeedStore
    
    init(store: FeedStore) {
        self.store = store
    }
    
    func save(_ items: [FeedItem]) {
        store.deleteCachedFeed()
    }
}

class FeedStore {
    var deleteCachedFeedCallCount = 0
    
    func deleteCachedFeed() {
        deleteCachedFeedCallCount += 1
    }
}

class CacheFeedUseCaseTests: XCTestCase {
    
    func test_init_doesNotDeleteCacheUponCreation() {
        let (_, store) = makeSut()
        XCTAssertEqual(store.deleteCachedFeedCallCount, 0)
    }
    
    func test_save_requestsCacheDeletion() {
        let items = [uniqueItem]
        let (sut, store) = makeSut()
        
        sut.save(items)
        XCTAssertEqual(store.deleteCachedFeedCallCount, 1)
    }
    
    private var uniqueItem: FeedItem {
        FeedItem(id: UUID(),
                 description: "Unique Test Item",
                 location: "any-location",
                 imageURL: anyURL
        )
    }
    
    private var anyURL: URL {
        URL(string: "http://any-url.com")!
    }
    
    private func makeSut(file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStore) {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store)
        assertNoMemoryLeak(sut, file: file, line: line)
        assertNoMemoryLeak(store, file: file, line: line)
        return(sut, store)
    }
    
}
