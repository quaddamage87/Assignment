//
//  ReviewCell.swift
//  Assignment
//
//  Created by Martijn Breet on 20/03/2020.
//  Copyright © 2020 Martijn Breet. All rights reserved.
//

import UIKit

class ReviewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var ratingView: RatingView!
    @IBOutlet weak var relativeTimeLabel: UILabel!
    @IBOutlet weak var reviewTextLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
