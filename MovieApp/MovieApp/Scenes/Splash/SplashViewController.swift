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
        imageView.image = UIImage(named: "AppLogoTransparent")
        imageView.tintColor = AppColor.primary
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "MovieApp"
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textColor = AppColor.primaryText
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let taglineLabel: UILabel = {
        let label = UILabel()
        label.text = "GLI Assesment by Roby Setiawan"
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = AppColor.tertiaryText
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .center
        stackView.backgroundColor = AppColor.neutralComponent
        stackView.layer.cornerRadius = 16
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 24, left: 24, bottom: 24, right: 24)
        
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
        view.backgroundColor = AppColor.secondaryBg
        
        containerStackView.addArrangedSubview(logoImageView)
        containerStackView.addArrangedSubview(titleLabel)
        view.addSubview(containerStackView)
        view.addSubview(taglineLabel)
        
        NSLayoutConstraint.activate([
            logoImageView.widthAnchor.constraint(equalToConstant: 100),
            logoImageView.heightAnchor.constraint(equalToConstant: 100),
            
            containerStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            containerStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
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
                self.navigateNext()
            }
        )
    }

    private func navigateNext() {
        let hasSeenOnboarding = UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
        
        // GANTI: Sekarang targetnya adalah MainContainerViewController
        let nextVC: UIViewController = hasSeenOnboarding ? MainContainerViewController() : OnBoardingViewController()
        
        guard let window = view.window else { return }
        
        // Transisi ke "Sultan Mode"
        UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: {
            window.rootViewController = nextVC
        }, completion: nil)
    }

}
