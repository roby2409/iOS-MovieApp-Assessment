//
//  APIManagerTests.swift
//  MovieAppTests
//
//  Created by Roby Setiawan on 20/06/26.
//

import Foundation
import XCTest
@testable import MovieApp

final class MockURLProtocol: URLProtocol {

    
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data?))?

    
    static var lastRequest: URLRequest?

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        MockURLProtocol.lastRequest = request

        guard let handler = MockURLProtocol.requestHandler else {
            fatalError("MockURLProtocol.requestHandler not set. Set it before making a request in your test.")
        }

        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            if let data = data {
                client?.urlProtocol(self, didLoad: data)
            }
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}

    
    static func makeMockedSession() -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        return URLSession(configuration: configuration)
    }
}


final class MockReachability: NetworkReachability {
    var isConnected: Bool
    init(isConnected: Bool = true) {
        self.isConnected = isConnected
    }
}
final class APIManagerTests: XCTestCase {

    private var sut: APIManager!
    private var mockSession: URLSession!

    override func setUp() {
        super.setUp()
        mockSession = MockURLProtocol.makeMockedSession()
    }

    override func tearDown() {
        MockURLProtocol.requestHandler = nil
        MockURLProtocol.lastRequest = nil
        sut = nil
        mockSession = nil
        super.tearDown()
    }

    private func makeSUT(isConnected: Bool = true) -> APIManager {
        return APIManager(
            session: mockSession,
            baseURL: "https://api.themoviedb.org/3",
            apiKey: "dummy_api_key",
            reachability: MockReachability(isConnected: isConnected)
        )
    }

    // MARK: - URL building

    func test_request_buildsCorrectURL_withoutPath() {
        sut = makeSUT()
        let expectation = expectation(description: "request sent")

        MockURLProtocol.requestHandler = { request in
            XCTAssertEqual(request.url?.path, "/3/discover/movie")
            expectation.fulfill()
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            let json = #"{"page":1,"results":[],"totalPages":1,"totalResults":0}"#.data(using: .utf8)
            return (response, json)
        }

        sut.hitAPIWithResultAndError(endpoint: .discoverMovie, model: DummyMovieResponse.self) { _ in }
        waitForExpectations(timeout: 1)
    }

    func test_request_buildsCorrectURL_withDynamicPath() {
        sut = makeSUT()
        let expectation = expectation(description: "request sent")

        MockURLProtocol.requestHandler = { request in
            XCTAssertEqual(request.url?.path, "/3/discover/movie/27205")
            expectation.fulfill()
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            let json = #"{"id":27205,"title":"Inception"}"#.data(using: .utf8)
            return (response, json)
        }

        sut.hitAPIWithResultAndError(endpoint: .discoverMovie, path: "27205", model: DummyMovieDetail.self) { _ in }
        waitForExpectations(timeout: 1)
    }

    func test_request_appendsApiKey_asQueryItem() {
        sut = makeSUT()
        let expectation = expectation(description: "request sent")

        MockURLProtocol.requestHandler = { request in
            let components = URLComponents(url: request.url!, resolvingAgainstBaseURL: false)
            let apiKeyItem = components?.queryItems?.first { $0.name == "api_key" }
            XCTAssertEqual(apiKeyItem?.value, "dummy_api_key")
            expectation.fulfill()
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            let json = #"{"page":1,"results":[],"totalPages":1,"totalResults":0}"#.data(using: .utf8)
            return (response, json)
        }

        sut.hitAPIWithResultAndError(endpoint: .discoverMovie, model: DummyMovieResponse.self) { _ in }
        waitForExpectations(timeout: 1)
    }

    func test_request_rawQueryString_isParsedIntoURL() {
        sut = makeSUT()
        let expectation = expectation(description: "request sent")

        MockURLProtocol.requestHandler = { request in
            let components = URLComponents(url: request.url!, resolvingAgainstBaseURL: false)
            let communityIdItem = components?.queryItems?.first { $0.name == "communityId" }
            XCTAssertEqual(communityIdItem?.value, "abc123")
            expectation.fulfill()
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            let json = #"{"id":27205,"title":"Inception"}"#.data(using: .utf8)
            return (response, json)
        }

        sut.hitAPIWithResultAndError(endpoint: .discoverMovie, query: "communityId=abc123", model: DummyMovieDetail.self) { _ in }
        waitForExpectations(timeout: 1)
    }

    func test_request_sendsCorrectHTTPMethod() {
        sut = makeSUT()
        let expectation = expectation(description: "request sent")

        MockURLProtocol.requestHandler = { request in
            XCTAssertEqual(request.httpMethod, "DELETE")
            expectation.fulfill()
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, "{}".data(using: .utf8))
        }

        sut.hitAPIWithResultAndError(endpoint: .discoverMovie, path: "1", httpMethod: .delete, model: DummyEmptyResponse.self) { _ in }
        waitForExpectations(timeout: 1)
    }

    // MARK: - Decoding

    func test_request_success_decodesResponseCorrectly() {
        sut = makeSUT()
        let expectation = expectation(description: "decoded")

        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            let json = #"{"id":27205,"title":"Inception"}"#.data(using: .utf8)
            return (response, json)
        }

        sut.hitAPIWithResultAndError(endpoint: .discoverMovie, path: "27205", model: DummyMovieDetail.self) { result in
            switch result {
            case .success(let detail, _):
                XCTAssertEqual(detail.id, 27205)
                XCTAssertEqual(detail.title, "Inception")
            case .error:
                XCTFail("Expected success")
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func test_request_malformedJSON_returnsDecodingError() {
        sut = makeSUT()
        let expectation = expectation(description: "decode error")

        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            let json = #"{"wrong_field": "oops"}"#.data(using: .utf8)
            return (response, json)
        }

        sut.hitAPIWithResultAndError(endpoint: .discoverMovie, path: "27205", model: DummyMovieDetail.self) { result in
            switch result {
            case .success:
                XCTFail("Expected error")
            case .error(let error):
                if case .decodingFailed = error {
                    // pass
                } else {
                    XCTFail("Expected .decodingFailed, got \(error)")
                }
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    // MARK: - HTTP status code error mapping

    func test_request_404_returnsNotFoundError() {
        sut = makeSUT()
        let expectation = expectation(description: "404 error")

        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 404, httpVersion: nil, headerFields: nil)!
            return (response, "{}".data(using: .utf8))
        }

        sut.hitAPIWithResultAndError(endpoint: .discoverMovie, path: "999999", model: DummyMovieDetail.self) { result in
            switch result {
            case .success:
                XCTFail("Expected error")
            case .error(let error):
                XCTAssertEqual(error, .notFound)
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func test_request_500_returnsServerError() {
        sut = makeSUT()
        let expectation = expectation(description: "500 error")

        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 500, httpVersion: nil, headerFields: nil)!
            return (response, "{}".data(using: .utf8))
        }

        sut.hitAPIWithResultAndError(endpoint: .discoverMovie, model: DummyMovieResponse.self) { result in
            switch result {
            case .success:
                XCTFail("Expected error")
            case .error(let error):
                XCTAssertEqual(error, .serverError(statusCode: 500))
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    // MARK: - No internet (negative case)

    func test_request_noInternet_returnsErrorImmediately_withoutHittingNetwork() {
        sut = makeSUT(isConnected: false)
        let expectation = expectation(description: "no internet error")

        // Sengaja TIDAK set requestHandler — kalau ini ke-trigger berarti ada bug
        // (APIManager tetap nembak network padahal harusnya short-circuit duluan).
        MockURLProtocol.requestHandler = { _ in
            XCTFail("Should not hit network when offline")
            throw NetworkError.unknown("should not be called")
        }

        sut.hitAPIWithResultAndError(endpoint: .discoverMovie, model: DummyMovieResponse.self) { result in
            switch result {
            case .success:
                XCTFail("Expected no internet error")
            case .error(let error):
                XCTAssertEqual(error, .noInternetConnection)
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    // MARK: - Timeout / generic URLError

    func test_request_urlSessionError_mapsToNetworkError() {
        sut = makeSUT()
        let expectation = expectation(description: "timeout error")

        MockURLProtocol.requestHandler = { _ in
            throw URLError(.timedOut)
        }

        sut.hitAPIWithResultAndError(endpoint: .discoverMovie, model: DummyMovieResponse.self) { result in
            switch result {
            case .success:
                XCTFail("Expected error")
            case .error(let error):
                XCTAssertEqual(error, .timeout)
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
}

// MARK: - Dummy models used only for these tests

struct DummyMovieResponse: Decodable {
    let page: Int
    let results: [DummyMovieItem]
    let totalPages: Int
    let totalResults: Int
}

struct DummyMovieItem: Decodable {
    let id: Int
}

struct DummyMovieDetail: Decodable {
    let id: Int
    let title: String
}

struct DummyEmptyResponse: Decodable {}
