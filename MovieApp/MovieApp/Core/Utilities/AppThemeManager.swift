//
//  AppThemeManager.swift
//  MovieApp
//
//  Created by Roby Setiawan on 20/06/26.
//

import UIKit

class AppThemeManager {
    static let shared = AppThemeManager()
    
    var currentStyle: UIUserInterfaceStyle {
        get { UIUserInterfaceStyle(rawValue: UserDefaults.standard.integer(forKey: "app_theme")) ?? .unspecified }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: "app_theme")
            applyTheme(style: newValue)
        }
    }
    
    func applyTheme(style: UIUserInterfaceStyle) {
        let scenes = UIApplication.shared.connectedScenes
        let windowScenes = scenes.compactMap { $0 as? UIWindowScene }
        
        windowScenes.forEach { windowScene in
            windowScene.windows.forEach { window in
                window.overrideUserInterfaceStyle = style
            }
        }
    }
}
