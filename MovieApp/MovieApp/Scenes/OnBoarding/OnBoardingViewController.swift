//
//  OnBoardingViewController.swift
//  MovieApp
//
//  Created by Roby Setiawan on 20/06/26.
//

import UIKit

class OnBoardingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupUI()
    }

    private func setupUI() {
        let titleLabel = UILabel()
        titleLabel.text = "Welcome to Movie"
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let descLabel = UILabel()
        descLabel.text = "Discover popular movies, watch trailers, and read reviews."
        descLabel.textColor = .lightGray
        descLabel.font = .systemFont(ofSize: 16)
        descLabel.textAlignment = .center
        descLabel.numberOfLines = 0
        descLabel.translatesAutoresizingMaskIntoConstraints = false

        let getStartedButton = UIButton(type: .system)
        getStartedButton.setTitle("Get Started", for: .normal)
        getStartedButton.setTitleColor(.white, for: .normal)
        getStartedButton.backgroundColor = .systemRed
        getStartedButton.layer.cornerRadius = 8
        getStartedButton.translatesAutoresizingMaskIntoConstraints = false
        getStartedButton.addTarget(self, action: #selector(getStartedTapped), for: .touchUpInside)

        view.addSubview(titleLabel)
        view.addSubview(descLabel)
        view.addSubview(getStartedButton)

        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -60),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 24),

            descLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            descLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            descLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),

            getStartedButton.topAnchor.constraint(equalTo: descLabel.bottomAnchor, constant: 32),
            getStartedButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            getStartedButton.widthAnchor.constraint(equalToConstant: 200),
            getStartedButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }

    @objc private func getStartedTapped() {
        UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")

        guard let window = view.window else { return }
        window.rootViewController = MainContainerViewController()
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
    }
}
