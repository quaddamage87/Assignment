//
//  RatingView.swift
//  Assignment
//
//  Created by Martijn Breet on 19/03/2020.
//  Copyright © 2020 Martijn Breet. All rights reserved.
//

import UIKit

@IBDesignable
class RatingView: UIStackView {
    
    private var ratingStars = [UIImageView]()
    
    @IBInspectable var starSize: CGSize = CGSize(width: 24.0, height: 24.0) {
        didSet {
            setupStars()
        }
    }
    var rating: Double? = 3.5 {
        didSet {
            setupStars()
        }
    }
    
    //MARK: initalization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupStars()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupStars()
    }
    
    //MARK: private methods
    private func setupStars() {
        
        // remove existing stars
        for star in ratingStars {
            removeArrangedSubview(star)
            star.removeFromSuperview()
        }
        ratingStars.removeAll()
        
        // only show stars when there is a rating present
        if let realRating = self.rating {
            for i in 0..<5 {
                let diff = realRating - Double(i)
                var startType = ""
                if diff < 0.25 {
                    startType = "emptyStar"
                } else if diff < 0.75 {
                    startType = "halfStar"
                } else {
                    startType = "filledStar"
                }
                let bundle = Bundle(for: type(of: self))
                let starImage = UIImage(named: startType, in: bundle, compatibleWith: self.traitCollection)
                let star = UIImageView(image: starImage)
                star.contentMode = .scaleAspectFit
                
                // Add constraints
                star.translatesAutoresizingMaskIntoConstraints = false
                star.heightAnchor.constraint(equalToConstant: starSize.height).isActive = true
                star.widthAnchor.constraint(equalToConstant: starSize.width).isActive = true
                
                addArrangedSubview(star)
                ratingStars.append(star)
            }
        }
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
