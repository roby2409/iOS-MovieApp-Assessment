//
//  HomeViewController.swift
//  MovieApp
//
//  Created by Roby Setiawan on 20/06/26.
//

import UIKit

// --- HOME: Tampilkan TabBar ---
class HomeViewController: UIViewController {

    @IBOutlet weak var appBarview: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColor.secondaryBg
        appBarview.backgroundColor = AppColor.secondaryBg
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
}
