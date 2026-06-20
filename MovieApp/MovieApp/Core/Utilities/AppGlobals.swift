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
