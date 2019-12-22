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

//    self.backgroundColor = .white

    // swiftlint:disable force_cast
    // Add and configure Favorite button
    let fave = self.viewWithTag(331) as! UIButton
    // swiftlint:enable force_cast

    fave.tintColor = .systemBlue

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
