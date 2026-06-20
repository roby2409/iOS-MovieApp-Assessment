import UIKit

class CustomBottomBar: UIView {
    private let stackView = UIStackView()
    var onTabSelected: ((Int) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        backgroundColor = AppColor.neutralComponent
        layer.cornerRadius = 25
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = CGSize(width: 0, height: -2)
        
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        addBtn(title: "Home", icon: "house", tag: 0)
        addBtn(title: "Settings", icon: "gearshape", tag: 1)
    }

    private func addBtn(title: String, icon: String, tag: Int) {
        let btn = UIButton(type: .system)
        var config = UIButton.Configuration.plain()
        
        config.title = title
        config.image = UIImage(systemName: icon)
        config.imagePlacement = .top
        config.imagePadding = 4
        config.titleAlignment = .center
        config.baseForegroundColor = AppColor.primary
        
        config.attributedTitle = AttributedString(title, attributes: AttributeContainer([
            .font: UIFont.systemFont(ofSize: 12, weight: .medium)
        ]))
        
        btn.configuration = config
        btn.tag = tag
        btn.addTarget(self, action: #selector(tapped), for: .touchUpInside)
        stackView.addArrangedSubview(btn)
    }

    @objc private func tapped(_ sender: UIButton) { onTabSelected?(sender.tag) }
    
    func updateSelection(selectedIndex: Int) {
        for (index, subview) in stackView.arrangedSubviews.enumerated() {
            if let btn = subview as? UIButton {
                let color = (index == selectedIndex) ? AppColor.primary : AppColor.tertiaryText
                btn.tintColor = color
                var config = btn.configuration
                config?.baseForegroundColor = color
                btn.configuration = config
            }
        }
    }
}

class MainContainerViewController: UIViewController, UINavigationControllerDelegate {
    
    private let bottomBar = CustomBottomBar()
    private var viewControllers: [UINavigationController] = []
    private var selectedIndex: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
        setupBottomBarLayout()
    }

    private func setupTabs() {
        let homeNav = UINavigationController(rootViewController: HomeViewController())
        let settingNav = UINavigationController(rootViewController: SettingsViewController())
        
        [homeNav, settingNav].forEach {
            $0.delegate = self
            addChild($0)
            view.addSubview($0.view)
            viewControllers.append($0)
        }
        selectTab(0)
    }

    private func setupBottomBarLayout() {
        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bottomBar)
        NSLayoutConstraint.activate([
            bottomBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            bottomBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            bottomBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            bottomBar.heightAnchor.constraint(equalToConstant: 70)
        ])
        
        bottomBar.onTabSelected = { [weak self] index in self?.selectTab(index) }
    }

    private func selectTab(_ index: Int) {
        viewControllers.forEach { $0.view.isHidden = ($0 != viewControllers[index]) }
        selectedIndex = index
        bottomBar.updateSelection(selectedIndex: index)
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        let isRoot = viewController == navigationController.viewControllers.first
        
        UIView.animate(withDuration: 0.3) {
            self.bottomBar.alpha = isRoot ? 1.0 : 0.0
        }
    }
}
