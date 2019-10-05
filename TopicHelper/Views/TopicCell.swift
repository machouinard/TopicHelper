//
//  TopicCell.swift
//  TopicHelper
//
//  Created by Mark Chouinard on 9/15/19.
//  Copyright © 2019 Mark Chouinard. All rights reserved.
//

import UIKit

class TopicCell: UITableViewCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var details: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: - Helper methods
    func configure(for topic: Topic) {
        
        self.layoutMargins = UIEdgeInsets.zero
        self.contentView.layoutMargins.right = 20
        
        // Add and configure Favorite button
        let fave = self.viewWithTag(331) as! UIButton
        fave.addTarget(nil, action: #selector(TopicsViewController.toggleFavorite(_:)), for: .touchUpInside)
//        fave.translatesAutoresizingMaskIntoConstraints = false
        fave.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        fave.contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        fave.imageView?.contentMode = .scaleAspectFit
        fave.titleLabel?.text = ""

        fave.tintColor = .white
        
        var imageName = String()
        
        if topic.isFavorite {
            imageName = "star-fill"
        } else {
            imageName = "star-open"
        }
        
        let faveImage = UIImage(named: imageName)?.withRenderingMode(.alwaysTemplate)
        fave.setImage(faveImage, for: .normal)
        
        if let detailsText = topic.details {
            details.text = detailsText
        } else {
            details.text = ""
        }
        if let titleText = topic.title {
            title.text = titleText
        } else {
            title.text = ""
        }
    }

}
