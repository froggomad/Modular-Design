//
//  FeedItem.swift
//  EssentialFeed
//
//  Created by Kenneth Dubroff on 5/24/21.
//

import Foundation

public struct FeedItem: Equatable {
    let id: UUID
    let description: String?
    let location: String?
    let imageURL: URL
}
