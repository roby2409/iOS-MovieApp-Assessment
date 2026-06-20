//
//  MovieAppTests.swift
//  MovieAppTests
//
//  Created by Roby Setiawan on 19/06/26.
//

import XCTest
@testable import MovieApp

final class MovieAppTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
        print("⏳ url \(Environment.shared.configuration(.baseUrl))")

        let expectation = expectation(description: "API call completes")

        APIManager.shared.hitAPIWithResultAndError(
            endpoint: .discoverMovie,
            model: DiscoverMovie.self
        ) { result in
            switch result {
            case .success(let data, _):
                print("Page: \(data.page ?? 0)")
                print("Total Pages: \(data.totalPages ?? 0)")
                print("Total Results: \(data.totalResults ?? 0)")
                print("==================================\n")

            case .error(let error):
                print("\n==================================")
                print(error.userMessage)
                print("==================================\n")
            }

            expectation.fulfill()
        }

        waitForExpectations(timeout: 30)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
