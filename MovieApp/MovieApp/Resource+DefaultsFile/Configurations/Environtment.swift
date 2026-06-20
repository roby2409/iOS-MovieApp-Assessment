//
//  Environtment.swift
//  MovieApp
//
//  Created by Roby Setiawan on 19/06/26.
//

import Foundation

struct Environment {
    
    static let shared: Environment = Environment()
    
    enum PlistKey: String {
        case baseUrl = "TMDB_BASE_URL"
        case apiKey = "TMDB_API_KEY"
        case scheme = "CONFIGURATION"
    }
    
    enum AppEnvironment: String {
        case dev = "Debug"
        case prod = "Release"
    }

    private var infoDict: [String: Any] {
        if let dict = Bundle.main.infoDictionary {
            return dict
        } else {
            fatalError("Plist file not found")
        }
    }
    
    func configuration(_ key: PlistKey) -> String {
        return infoDict[key.rawValue] as? String ?? ""
    }
    
    var getEnvi: AppEnvironment {
        let scheme = Environment.shared.configuration(.scheme)
        return AppEnvironment(rawValue: scheme) ?? .dev
    }
}
