//
//  HomeViewController.swift
//  MovieApp
//
//  Created by Roby Setiawan on 20/06/26.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var appBarView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColor.secondaryBg
        appBarView.backgroundColor = AppColor.secondaryBg
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
}
