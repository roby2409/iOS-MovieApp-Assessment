//
//  ThemeViewController.swift
//  MovieApp
//
//  Created by Roby Setiawan on 20/06/26.
//

import UIKit

class ThemeViewController: UIViewController {

    @IBOutlet weak var navTitleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    private let themes: [(title: String, style: UIUserInterfaceStyle)] = [
        ("Sistem Default", .unspecified),
        ("Terang (Light)", .light),
        ("Gelap (Dark)", .dark)
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    private func setupUI() {
        view.backgroundColor = AppColor.secondaryBg
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.isScrollEnabled = false
        tableView.bounces = false
        tableView.showsVerticalScrollIndicator = false

    }
    
    @IBAction func backAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

// MARK: - TableView Methods
extension ThemeViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return themes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        let theme = themes[indexPath.row]
        
        cell.textLabel?.text = theme.title
        
        // Tandai centang kalau tema ini sedang aktif
        let currentStyle = AppThemeManager.shared.currentStyle
        cell.accessoryType = (theme.style == currentStyle) ? .checkmark : .none
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Update tema
        let selectedTheme = themes[indexPath.row]
        AppThemeManager.shared.currentStyle = selectedTheme.style
        
        // Refresh tabel biar centangnya pindah
        tableView.reloadData()
    }
}
