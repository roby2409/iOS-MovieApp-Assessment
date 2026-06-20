//
//  NetworkMonitor.swift
//  MovieApp
//
//  Created by Roby Setiawan on 19/06/26.
//

import Foundation
import Network

public protocol NetworkReachability {
    var isConnected: Bool { get }
}

public final class NetworkMonitor: NetworkReachability {
    public static let shared = NetworkMonitor()

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "com.movieapp.networkmonitor")

    public private(set) var isConnected: Bool = true

    public var onStatusChange: ((Bool) -> Void)?

    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }
            let connected = path.status == .satisfied
            self.isConnected = connected
            mainThread { self.onStatusChange?(connected) }
        }
        monitor.start(queue: queue)
    }
}
