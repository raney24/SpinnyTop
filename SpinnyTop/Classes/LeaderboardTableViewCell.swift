//
//  LeaderboardTableViewCell.swift
//  SpinnyTop
//
//  Created by Kyle Raney on 1/10/18.
//  Copyright © 2018 Kyle Raney. All rights reserved.
//

import UIKit

class LeaderboardTableViewCell: UITableViewCell {
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var lifetimeRotationsLabel: UILabel!
    @IBOutlet weak var maxSpinRPSLabel: UILabel!
    @IBOutlet weak var maxDurationLabel: UILabel!
    @IBOutlet weak var maxRotationsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
