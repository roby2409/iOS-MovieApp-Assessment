//
//  SettingsViewModel.swift
//  MovieApp
//
//  Created by Roby Setiawan on 20/06/26.
//

import UIKit

class SettingsViewModel {
    
    var menuItems: [SettingsItem] {
        return [
            SettingsItem(
                type: .theme,
                title: "Setelan Tema",
                subTitle: "Tema: \(getThemeName())",
                icon: "paintpalette"
            ),
            SettingsItem(type: .contact, title: "Kontak Kami", subTitle: "robysetiawan2409@gmail.com", icon: "person.text.rectangle"),
            SettingsItem(type: .version, title: "Versi Aplikasi", subTitle: "1.0.2", icon: "info.circle")
        ]
    }
    
    private func getThemeName() -> String {
        switch AppThemeManager.shared.currentStyle {
        case .light: return "Terang"
        case .dark:  return "Gelap"
        default:     return "Sistem Default"
        }
    }
}
