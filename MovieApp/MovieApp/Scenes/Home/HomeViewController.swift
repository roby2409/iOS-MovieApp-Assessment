//
//  HomeViewController.swift
//  MovieApp
//
//  Created by Roby Setiawan on 20/06/26.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var appBarView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    private var searchWorkItem: DispatchWorkItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupSearchBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    private func setupUI() {
        view.backgroundColor = AppColor.secondaryBg
        appBarView.backgroundColor = AppColor.secondaryBg
        collectionView.backgroundColor = AppColor.backgroundColor
    }
    
    private func setupSearchBar() {
        searchBar.delegate = self
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = "Search movies..."
        searchBar.backgroundImage = UIImage()
        if let searchField = searchBar.value(forKey: "searchField") as? UITextField {
            searchField.background = UIImage()
            searchField.backgroundColor = AppColor.secondaryBg
            searchField.layer.cornerRadius = 12
            searchField.clipsToBounds = true
            searchField.rightViewMode = .never
            searchField.textColor = .label
        }
        
    }
}


extension HomeViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchWorkItem?.cancel()
        let workItem = DispatchWorkItem { [weak self] in
            self?.performSearch(query: searchText)
        }
        searchWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: workItem)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchWorkItem?.cancel()
        if let query = searchBar.text {
            performSearch(query: query)
            searchBar.resignFirstResponder()
        }
    }
    
    private func performSearch(query: String) {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        debugPrint("API CALL TRIGGERED: \(query)")
    }
}
