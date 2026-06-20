//
//  HomeViewController.swift
//  MovieApp
//
//  Created by Roby Setiawan on 20/06/26.
//

import UIKit
import Foundation
import RxSwift
import RxCocoa

class HomeViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var appBarView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    private var searchWorkItem: DispatchWorkItem?
    
    private let viewModel = HomeViewModel()
    private let disposeBag = DisposeBag()
    
    private let spacing: CGFloat = 12
    private let columns = 2
    
    private var isLoadingMore = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
        setupSearchBar()
        setupBindings()
        viewModel.fetchMovies()
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
    
    private func setupCollectionView() {
        collectionView.register(MovieCollectionViewCell.self, forCellWithReuseIdentifier: MovieCollectionViewCell.reuseId)
        collectionView.register(
            LoadingFooterCollectionReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: LoadingFooterCollectionReusableView.reuseId
        )
        collectionView.dataSource = self
        collectionView.delegate = self
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumLineSpacing = spacing
            layout.minimumInteritemSpacing = spacing
            layout.sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
        }
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
    
    private func setupBindings() {
        viewModel.movies
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] movies in
                self?.collectionView.reloadData()
                debugPrint("Data updated: \(movies.count) movies")
            })
            .disposed(by: disposeBag)
        

        viewModel.errorMessage
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] message in
                self?.showToast(message: message)
            })
            .disposed(by: disposeBag)
        
        viewModel.isLoading
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] loading in
                guard let self else { return }
                // hanya tampilkan footer kalau ini load more (udah ada data sebelumnya)
                self.isLoadingMore = loading && !self.viewModel.movies.value.isEmpty
                self.collectionView.collectionViewLayout.invalidateLayout()
                
                if let footer = self.collectionView.visibleSupplementaryViews(ofKind: UICollectionView.elementKindSectionFooter).first as? LoadingFooterCollectionReusableView {
                    footer.setLoading(self.isLoadingMore)
                }
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - UICollectionViewDataSource
extension HomeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.movies.value.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieCollectionViewCell.reuseId, for: indexPath) as? MovieCollectionViewCell else {
            return UICollectionViewCell()
        }
        let movie = viewModel.movies.value[indexPath.item]
        cell.configure(with: movie)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionFooter,
              let footer = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: LoadingFooterCollectionReusableView.reuseId,
                for: indexPath
              ) as? LoadingFooterCollectionReusableView else {
            return UICollectionReusableView()
        }
        footer.setLoading(isLoadingMore)
        return footer
    }
}


// MARK: - UICollectionViewDelegateFlowLayout
extension HomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalSpacing = spacing * CGFloat(columns + 1)
        let width = (collectionView.bounds.width - totalSpacing) / CGFloat(columns)
        let height = width * 1.5 + 44
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        isLoadingMore ? CGSize(width: collectionView.bounds.width, height: 50) : .zero
    }
}

// MARK: - Infinite Scroll
extension HomeViewController: UICollectionViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.height
        
        guard contentHeight > 0 else { return }
        
        if offsetY > contentHeight - frameHeight - 200 {
            viewModel.fetchNextPage()
        }
    }
}

// MARK: - UISearchBarDelegate
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
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            viewModel.fetchMovies()
            return
        }

        viewModel.fetchMovies(searchKey: trimmed)
    }
}



