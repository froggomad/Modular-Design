//
//  RemoteFeedItem.swift
//  EssentialFeed
//
//  Created by Kenneth Dubroff on 7/27/21.
//

import Foundation

/// internal FeedItem Representation to keep implementation details out of test
internal struct RemoteFeedItem: Decodable {
    internal let id: UUID
    internal let description: String?
    internal let location: String?
    internal let image: URL
    
    var item: FeedItem {
        return FeedItem(id: id,
                        description: description,
                        location: location,
                        imageURL: image)
    }
}
