//
//  Utilities.swift
//  MovieApp
//
//  Created by Roby Setiawan on 19/06/26.
//

import Foundation

func mainThread(_ completion: @escaping () -> ()) {
    DispatchQueue.main.async {
        completion()
    }
}


enum TMDBImage {
    static let baseURL = "https://image.tmdb.org/t/p/"
    static func url(path: String?, size: String = "w500") -> URL? {
        guard let path else { return nil }
        return URL(string: baseURL + size + path)
    }
}
