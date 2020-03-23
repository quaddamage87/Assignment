//
//  PlaceCell.swift
//  Assignment
//
//  Created by Martijn Breet on 19/03/2020.
//  Copyright © 2020 Martijn Breet. All rights reserved.
//

import UIKit

class PlaceCell: UITableViewCell {
    
    
    @IBOutlet weak var placeNameLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var ratingView: RatingView!
    @IBOutlet weak var openClosedLabel: UILabel!
    @IBOutlet weak var reviewCountLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
