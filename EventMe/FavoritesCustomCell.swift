//
//  FavoritesCustomCell.swift
//  EventMe
//
//  Created by Michael McKenna on 12/23/15.
//  Copyright © 2015 Michael McKenna. All rights reserved.
//

import UIKit

class FavoritesCustomCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var monthAndDay: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var votesLabel: UILabel!
    @IBOutlet weak var upArrow: UIButton!
    @IBOutlet weak var downArrow: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}


