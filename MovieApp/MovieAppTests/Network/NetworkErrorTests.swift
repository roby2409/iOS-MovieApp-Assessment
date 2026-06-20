//
//  NetworkErrorTests.swift
//  MovieAppTests
//
//  Created by Roby Setiawan on 20/06/26.
//

import Foundation
import Testing
@testable import MovieApp

struct NetworkErrorSwiftTestingTests {

    @Test func noInternetConnection_mapsCorrectly() {
        let urlError = URLError(.notConnectedToInternet)
        let result = NetworkError.from(urlError)
        #expect(result == .noInternetConnection)
    }

    @Test func statusCode404_mapsToNotFound() {
        #expect(NetworkError.from(statusCode: 404) == .notFound)
    }

    @Test func statusCode200_returnsNil() {
        #expect(NetworkError.from(statusCode: 200) == nil)
    }
    
    @Test(arguments: [
        (401, NetworkError.unauthorized),
        (403, NetworkError.forbidden),
        (404, NetworkError.notFound),
        (500, NetworkError.serverError(statusCode: 500))
    ])
    func statusCode_mapsToCorrectError(statusCode: Int, expected: NetworkError) {
        #expect(NetworkError.from(statusCode: statusCode) == expected)
    }

    @Test func isRetryable_noInternet_isTrue() {
        #expect(NetworkError.noInternetConnection.isRetryable == true)
    }

    @Test func isRetryable_notFound_isFalse() {
        #expect(NetworkError.notFound.isRetryable == false)
    }
}
