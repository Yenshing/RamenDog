//
//  RamenPlaceInfoCell.swift
//  RamenGo
//
//  Created by Yencheng on 2017/2/14.
//  Copyright © 2017年 GJTeam. All rights reserved.
//

import UIKit

class RamenPlaceInfoCell: UITableViewCell {

    @IBOutlet weak var ramenView: UIView!
    @IBOutlet weak var ramenTitle: UILabel!
    @IBOutlet weak var ramenDistance: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
