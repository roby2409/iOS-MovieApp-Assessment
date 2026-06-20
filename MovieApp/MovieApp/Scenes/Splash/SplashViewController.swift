//
//  SplashViewController.swift
//  MovieApp
//
//  Created by Roby Setiawan on 20/06/26.
//

import UIKit

class SplashViewController: UIViewController {
    
    // MARK: - UI Components
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "popcorn.fill")
        imageView.tintColor = .systemRed
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "MovieApp"
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let taglineLabel: UILabel = {
        let label = UILabel()
        label.text = "GLI Assesment by Roby Setiawan"
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupInitialAnimationState()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startSplashAnimation()
    }
    
    // MARK: - Setup UI & Layout
    private func setupLayout() {
        view.backgroundColor = .black
        
        containerStackView.addArrangedSubview(logoImageView)
        containerStackView.addArrangedSubview(titleLabel)
        view.addSubview(containerStackView)
        view.addSubview(taglineLabel)
        
        NSLayoutConstraint.activate([
            logoImageView.widthAnchor.constraint(equalToConstant: 100),
            logoImageView.heightAnchor.constraint(equalToConstant: 100),
            
            containerStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            taglineLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            taglineLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            taglineLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])
    }
    
    private func setupInitialAnimationState() {
        containerStackView.alpha = 0.0
        containerStackView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        
        taglineLabel.alpha = 0.0
        taglineLabel.transform = CGAffineTransform(translationX: 0, y: 20)
    }
    
    // MARK: - Animation Logic
    private func startSplashAnimation() {
        UIView.animate(
            withDuration: 0.8,
            delay: 0.0,
            usingSpringWithDamping: 0.6,
            initialSpringVelocity: 0.2,
            options: .curveEaseOut,
            animations: {
                self.containerStackView.alpha = 1.0
                self.containerStackView.transform = .identity
            },
            completion: nil
        )
        
        UIView.animate(
            withDuration: 0.6,
            delay: 0.4,
            options: .curveEaseOut,
            animations: {
                self.taglineLabel.alpha = 1.0
                self.taglineLabel.transform = .identity
            },
            completion: { _ in
                debugPrint("hold continue to onboarding or homescreen")
            }
        )
    }

    
}
