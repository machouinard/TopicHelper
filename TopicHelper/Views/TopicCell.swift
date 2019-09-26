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
    
    // MARK: - Helper method
    func configure(for topic: Topic) {
        
        if let det = topic.details {
            details.text = det
        } else {
            details.text = ""
        }
        if let tit = topic.title {
            title.text = tit
        } else {
            title.text = ""
        }
    }

}
