//
//  AppColor.swift
//  MovieApp
//
//  Created by Roby Setiawan on 20/06/26.
//

import UIKit

import UIKit

struct AppColor {
    
    private static func getColor(_ name: String) -> UIColor {
        return UIColor(named: name) ?? .white
    }
    static var backgroundColor: UIColor { getColor("backgroundColor") }
    static var colorMainTopBackground: UIColor { getColor("colorMainTopBackground") }
    static var primary: UIColor { getColor("primary") }
    static var secondaryBg: UIColor { getColor("secondaryBg") }
    static var primaryText: UIColor { getColor("primaryText") }
    static var tertiaryText: UIColor { getColor("tertiaryText") }
    static var neutralComponent: UIColor { getColor("neutralComponent") }
}
