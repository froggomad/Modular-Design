//
//  XCTestCase+assertNoMemoryLeak.swift
//  EssentialFeedTests
//
//  Created by Kenneth Dubroff on 5/30/21.
//

import XCTest

extension XCTestCase {
    func assertNoMemoryLeak(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential retain cycle.", file: file, line: line)
        }
    }
}
