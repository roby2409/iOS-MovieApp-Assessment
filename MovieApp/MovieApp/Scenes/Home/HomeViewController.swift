//
//  HomeViewController.swift
//  MovieApp
//
//  Created by Roby Setiawan on 20/06/26.
//

import UIKit

// --- HOME: Tampilkan TabBar ---
class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColor.secondaryBg
        title = "Home"
        
        let btn = UIButton(type: .system)
        btn.setTitle("Go to Detail (Hide Bar)", for: .normal)
        btn.frame = CGRect(x: 100, y: 200, width: 200, height: 50)
        btn.addAction(UIAction { _ in
            self.navigationController?.pushViewController(DetailViewController(), animated: true)
        }, for: .touchUpInside)
        view.addSubview(btn)
    }
}
