//
//  MovieDetailViewModel.swift
//  MovieApp
//
//  Created by Roby Setiawan on 21/06/26.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa



// MARK: - Movie Detail
struct MovieDetail: Codable {
    let id: Int?
    let title: String?
    let tagline: String?
    let overview: String?
    let posterPath: String?
    let backdropPath: String?
    let releaseDate: String?
    let runtime: Int?
    let voteAverage: Double?
    let voteCount: Int?
    let status: String?
    let genres: [Genre]?
    
    enum CodingKeys: String, CodingKey {
        case id, title, tagline, overview, status, genres
        case posterPath
        case backdropPath
        case releaseDate
        case runtime
        case voteAverage
        case voteCount
    }
}

struct Genre: Codable {
    let id: Int?
    let name: String?
}

// MARK: - Videos
struct VideoResponse: Codable {
    let id: Int?
    let results: [Video]?
}

struct Video: Codable {
    let id: String?
    let key: String?
    let name: String?
    let site: String?
    let type: String?
    let official: Bool?
    let publishedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id, key, name, site, type, official
        case publishedAt
    }
    
    var isYouTubeTrailer: Bool {
        site == "YouTube" && type == "Trailer"
    }
    
    var thumbnailURL: URL? {
        guard let key else { return nil }
        return URL(string: "https://img.youtube.com/vi/\(key)/hqdefault.jpg")
    }
    
    var youtubeURL: URL? {
        guard let key else { return nil }
        return URL(string: "https://www.youtube.com/watch?v=\(key)")
    }
}

// MARK: - Reviews
struct ReviewResponse: Codable {
    let id: Int?
    let page: Int?
    let results: [Review]?
    let totalPages: Int?
    let totalResults: Int?
    
    enum CodingKeys: String, CodingKey {
        case id, page, results
        case totalPages
        case totalResults
    }
}

struct Review: Codable {
    let author: String?
    let authorDetails: AuthorDetails?
    let content: String?
    let createdAt: String?
    let id: String?
    let url: String?
    
    enum CodingKeys: String, CodingKey {
        case author
        case authorDetails
        case content
        case createdAt
        case id, url
    }
}

struct AuthorDetails: Codable {
    let name: String?
    let username: String?
    let avatarPath: String?
    let rating: Double?
    
    enum CodingKeys: String, CodingKey {
        case name, username, rating
        case avatarPath
    }
    
    var avatarURL: URL? {
        guard let avatarPath, !avatarPath.isEmpty else { return nil }
        if avatarPath.hasPrefix("/https") {
            return URL(string: String(avatarPath.dropFirst()))
        }
        let result = URL(string: TMDBImage.baseURL + "w185" + avatarPath)
        return result
    }
}




