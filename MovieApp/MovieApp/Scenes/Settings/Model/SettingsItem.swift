//
//  SettingsItem.swift
//  MovieApp
//
//  Created by Roby Setiawan on 20/06/26.
//

import Foundation
import UIKit

enum SettingsType {
    case theme, contact, version
}

struct SettingsItem {
    let type: SettingsType
    let title: String
    let subTitle: String?
    let icon: String
}
