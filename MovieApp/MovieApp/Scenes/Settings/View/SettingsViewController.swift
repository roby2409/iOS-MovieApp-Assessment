//
//  SettingsViewController.swift
//  MovieApp
//
//  Created by Roby Setiawan on 20/06/26.
//

import UIKit

class SettingsViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Settings"
        setupTableView()
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SettingsCell")
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
    }
}

// MARK: - UITableViewDataSource, Delegate
extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "SettingsCell")
        
        switch indexPath.section {
        case 0:
            cell.textLabel?.text = "Setelan Tema"
            cell.detailTextLabel?.text = "Tema: Terang"
            cell.imageView?.image = UIImage(systemName: "lightbulb")
        case 1:
            cell.textLabel?.text = "Kontak Kami"
            cell.detailTextLabel?.text = "WA: 0812xxx / Email: robysetiawan2409@email.com"
            cell.imageView?.image = UIImage(systemName: "envelope")
        case 2:
            cell.textLabel?.text = "Versi Aplikasi"
            cell.detailTextLabel?.text = "1.0.2 (Build 45)"
            cell.imageView?.image = UIImage(systemName: "info.circle")
        default:
            break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}
