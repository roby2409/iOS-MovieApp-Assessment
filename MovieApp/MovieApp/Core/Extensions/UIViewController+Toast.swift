//
//  UIViewController+Toast.swift
//  MovieApp
//
//  Created by Roby Setiawan on 20/06/26.
//

import UIKit

extension UIViewController {
    
    func showToast(message: String, duration: TimeInterval = 2.0) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first(where: { $0.isKeyWindow }) else {
            return
        }
        let toastLabel = UILabel(frame: CGRect(x: 20, y: self.view.frame.size.height - 120, width: self.view.frame.size.width - 40, height: 40))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center
        toastLabel.font = UIFont.systemFont(ofSize: 14)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds = true
        
        window.addSubview(toastLabel)
        
        // Animasi muncul dan hilang
        UIView.animate(withDuration: 0.5, delay: duration, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: { _ in
            toastLabel.removeFromSuperview()
        })
    }
}
