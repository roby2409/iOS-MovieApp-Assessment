//
//  DiscoverMovieTest.swift
//  MovieAppTests
//
//  Created by Roby Setiawan on 20/06/26.
//

import XCTest
@testable import MovieApp

final class DiscoverMovieTest: XCTestCase {
  
    func test_discoverMovie_decodesValidJSON_withAllLanguages() throws {
        
        let jsonString = """
        {
          "page": 1,
          "results": [
            {
              "adult": false,
              "backdrop_path": "/8YFL5QQVPy3AgrEQxNYVSgiPEbe.jpg",
              "genre_ids": [28, 12, 878],
              "id": 640146,
              "original_language": "en",
              "original_title": "Ant-Man and the Wasp: Quantumania",
              "overview": "Super-Hero partners Scott Lang and Hope van Dyne...",
              "popularity": 9272.643,
              "poster_path": "/ngl2FKBlU4fhbdsrtdom9LVLBXw.jpg",
              "release_date": "2023-02-15",
              "title": "Ant-Man and the Wasp: Quantumania",
              "video": false,
              "vote_average": 6.5,
              "vote_count": 1856
            },
            {
              "id": 502356,
              "original_language": "en",
              "title": "The Super Mario Bros. Movie"
            },
            {
              "id": 1008005,
              "original_language": "es",
              "title": "The Communion Girl"
            },
            {
              "id": 849869,
              "original_language": "ko",
              "title": "Kill Boksoon"
            },
            {
              "id": 946310,
              "original_language": "nl",
              "title": "Pirates Down the Street II"
            }
          ],
          "total_pages": 38020,
          "total_results": 760385
        }
        """
        
        
        let jsonData = try XCTUnwrap(jsonString.data(using: .utf8), "Gagal mengonversi JSON string ke Data")
        
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        
        let decodedResponse = try decoder.decode(DiscoverMovie.self, from: jsonData)
        
        
        XCTAssertEqual(decodedResponse.page, 1)
        XCTAssertEqual(decodedResponse.totalPages, 38020)
        XCTAssertEqual(decodedResponse.totalResults, 760385)
        
        let results = try XCTUnwrap(decodedResponse.results)
        XCTAssertEqual(results.count, 5, "Jumlah item movie di dalam array harusnya ada 5")
        
        let firstMovie = results[0]
        XCTAssertEqual(firstMovie.id, 640146)
        XCTAssertEqual(firstMovie.title, "Ant-Man and the Wasp: Quantumania")
        XCTAssertEqual(firstMovie.adult, false)
        XCTAssertEqual(firstMovie.voteAverage, 6.5)
        XCTAssertEqual(firstMovie.genreIds, [28, 12, 878])
        
    }
}
