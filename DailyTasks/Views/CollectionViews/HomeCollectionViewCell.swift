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
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var subView: UIView!
    
    var doneButtonAction: (() -> Void)?
    
    var name = ""
    var priority = ""
    var time = ""

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        subView.layer.cornerRadius = 23
        
        doneButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }
    
    @objc func buttonTapped() {
        doneButtonAction?()
    }
}
