//
//  NetworkError.swift
//  MovieApp
//
//  Created by Roby Setiawan on 19/06/26.
//

import Foundation

public enum NetworkError: Error, Equatable {
    case noInternetConnection
    case timeout
    case invalidURL
    case invalidResponse
    case decodingFailed(String)
    case unauthorized                  // 401
    case forbidden                     // 403
    case notFound                      // 404
    case serverError(statusCode: Int)  // 5xx
    case clientError(statusCode: Int)  // other 4xx
    case cancelled
    case unknown(String)

    /// Map a raw URLError / generic Error into our NetworkError
    public static func from(_ error: Error) -> NetworkError {
        if let networkError = error as? NetworkError {
            return networkError
        }

        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost:
                return .noInternetConnection
            case .timedOut:
                return .timeout
            case .cancelled:
                return .cancelled
            case .badURL, .unsupportedURL:
                return .invalidURL
            default:
                return .unknown(urlError.localizedDescription)
            }
        }

        if error is DecodingError {
            return .decodingFailed(error.localizedDescription)
        }

        return .unknown(error.localizedDescription)
    }

    /// Map HTTP status code into NetworkError
    public static func from(statusCode: Int) -> NetworkError? {
        switch statusCode {
        case 200...299:
            return nil
        case 401:
            return .unauthorized
        case 403:
            return .forbidden
        case 404:
            return .notFound
        case 400...499:
            return .clientError(statusCode: statusCode)
        case 500...599:
            return .serverError(statusCode: statusCode)
        default:
            return .unknown("Unexpected status code: \(statusCode)")
        }
    }

    /// User-facing message — pakai ini buat ditampilin di ErrorStateView
    public var userMessage: String {
        switch self {
        case .noInternetConnection:
            return "No internet connection. Please check your network and try again."
        case .timeout:
            return "The request timed out. Please try again."
        case .invalidURL:
            return "Something went wrong. Please try again later."
        case .invalidResponse:
            return "Unexpected response from server."
        case .decodingFailed:
            return "Failed to process the data. Please try again."
        case .unauthorized:
            return "Your session has expired. Please log in again."
        case .forbidden:
            return "You don't have permission to access this content."
        case .notFound:
            return "The content you're looking for was not found."
        case .serverError:
            return "Something went wrong on our end. Please try again later."
        case .clientError:
            return "Something went wrong with your request."
        case .cancelled:
            return "Request was cancelled."
        case .unknown(let message):
            return message
        }
    }

    public var isRetryable: Bool {
        switch self {
        case .noInternetConnection, .timeout, .serverError, .unknown:
            return true
        default:
            return false
        }
    }
}
