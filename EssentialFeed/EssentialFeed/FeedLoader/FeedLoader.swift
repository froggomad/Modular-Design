//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Kenneth Dubroff on 5/24/21.
//

import Foundation

public enum LoadFeedResult {
    case success([FeedItem])
    case failure(Error)
}

protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
