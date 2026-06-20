//
//  MovieDetailViewModel.swift
//  MovieApp
//
//  Created by Roby Setiawan on 21/06/26.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa


class MovieDetailViewModel {
    let movieId: Int
    
    let detail = BehaviorRelay<MovieDetail?>(value: nil)
    let trailer = BehaviorRelay<Video?>(value: nil)
    let reviews = BehaviorRelay<[Review]>(value: [])
    let totalReviews = BehaviorRelay<Int>(value: 0)
    
    let isLoading = BehaviorRelay<Bool>(value: false)
    let errorMessage = PublishRelay<String>()
    
    private let disposeBag = DisposeBag()
    
    init(movieId: Int) {
        self.movieId = movieId
    }
    
    func fetchAll() {
        isLoading.accept(true)
        
        let detailObservable = fetchDetail()
        let videosObservable = fetchVideos()
        let reviewsObservable = fetchReviews(page: 1)
        
        Observable.zip(detailObservable, videosObservable, reviewsObservable)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] detail, videoResponse, reviewResponse in
                guard let self else { return }
                self.detail.accept(detail)
                
                let videos = videoResponse.results ?? []
                self.trailer.accept(
                    videos.first(where: { $0.isYouTubeTrailer && $0.official == true })
                    ?? videos.first(where: { $0.isYouTubeTrailer })
                )
                
                self.reviews.accept(reviewResponse.results ?? [])
                self.totalReviews.accept(reviewResponse.totalResults ?? 0)
                self.isLoading.accept(false)
            }, onError: { [weak self] error in
                debugPrint("❌ MovieDetail error: \(error)")
                self?.errorMessage.accept("Failed to load movie detail")
                self?.isLoading.accept(false)
            })
            .disposed(by: disposeBag)
    }
    
    private func fetchDetail() -> Observable<MovieDetail> {
        Observable<MovieDetail>.create { [weak self] observer in
            guard let self else { return Disposables.create() }
            /**
            https://api.themoviedb.org/3/movie/1339713
             */
            let task = APIManager.shared.hitAPIWithResultAndError(
                endpoint: .movie,
                path: "\(self.movieId)",
                httpMethod: .get,
                model: MovieDetail.self
            ) { result in
                switch result {
                case .success(let data, _): observer.onNext(data); observer.onCompleted()
                case .error(let error): observer.onError(error)
                }
            }
            return Disposables.create { task?.cancel() }
        }
    }
    
    private func fetchVideos() -> Observable<VideoResponse> {
        Observable<VideoResponse>.create { [weak self] observer in
            guard let self else { return Disposables.create() }
            /**
             https://api.themoviedb.org/3/movie/1339713/videos
            */
            let task = APIManager.shared.hitAPIWithResultAndError(
                endpoint: .movie,
                path: "\(self.movieId)/videos",
                httpMethod: .get,
                model: VideoResponse.self
            ) { result in
                switch result {
                case .success(let data, _): observer.onNext(data); observer.onCompleted()
                case .error(let error): observer.onError(error)
                }
            }
            return Disposables.create { task?.cancel() }
        }
    }
    
    private func fetchReviews(page: Int) -> Observable<ReviewResponse> {
        Observable<ReviewResponse>.create { [weak self] observer in
            guard let self else { return Disposables.create() }
            /**
            https://api.themoviedb.org/3/movie/1339713/reviews
             */
            let task = APIManager.shared.hitAPIWithResultAndError(
                endpoint: .movie,
                path: "\(self.movieId)/reviews",
                httpMethod: .get,
                model: ReviewResponse.self
            ) { result in
                switch result {
                case .success(let data, _): observer.onNext(data); observer.onCompleted()
                case .error(let error): observer.onError(error)
                }
            }
            return Disposables.create { task?.cancel() }
        }
    }
}
