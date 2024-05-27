//
//  SearchTableViewCell.swift
//  DailyTasks
//
//  Created by Mac on 23/04/2024.
//

import UIKit

class SearchTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var viewDetailButton: UIButton!
    
    var viewDetailButtonAction: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        viewDetailButton.addTarget(self, action: #selector(viewDetailButtonTouchUpInside), for: .touchUpInside)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc func viewDetailButtonTouchUpInside() {
        viewDetailButtonAction?()
    }
    
}
