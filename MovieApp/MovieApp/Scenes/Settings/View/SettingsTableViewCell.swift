//
//  SettingsTableViewCell.swift
//  MovieApp
//
//  Created by Roby Setiawan on 20/06/26.
//

import UIKit

class SettingsTableViewCell: UITableViewCell {
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var btnNav: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        self.selectionStyle = .none
        setupCardStyle()
    }

    private func setupCardStyle() {
        
        cardView.layer.cornerRadius = 12
        cardView.layer.masksToBounds = true
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.1
        cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cardView.layer.shadowRadius = 4
        cardView.layer.masksToBounds = false
    }
    
    func configure(with item: SettingsItem) {
            
        titleLabel.text = item.title
        iconImageView.image = UIImage(systemName: item.icon)
        

        valueLabel.text = item.subTitle
        valueLabel.isHidden = (item.subTitle == nil)
        

        btnNav.isHidden = !(item.type == .theme)
        
        cardView.layer.cornerRadius = 12
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.1
        cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
    }

}
