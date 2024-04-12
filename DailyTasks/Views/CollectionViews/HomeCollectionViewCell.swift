//
//  HomeCollectionViewCell.swift
//  DailyTasks
//
//  Created by Mac on 10/04/2024.
//

import UIKit

class HomeCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var tagImageView: UIImageView!
    @IBOutlet weak var arrowRightImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var subView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        subView.layer.cornerRadius = 23
    }

}
