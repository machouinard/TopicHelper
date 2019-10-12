//
//  SettingsInfoHeader.swift
//  TopicHelper
//
//  Created by Mark Chouinard on 10/6/19.
//  Copyright © 2019 Mark Chouinard. All rights reserved.
//

import UIKit

class SettingsInfoHeader: UIView {

  // MARK: - Properties

  let settingsImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFill
    imageView.clipsToBounds = true
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.image = UIImage(named: "gear")?.withRenderingMode(.alwaysTemplate)

    return imageView
  }()

  let settingsViewLabel: UILabel = {
    let label = UILabel()
    label.text = "Topic Management"
    label.font = UIFont.systemFont(ofSize: 16)
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()

  let settingsViewSubLabel: UILabel = {
    let label = UILabel()
    label.text = "Some settings"
    label.font = UIFont.systemFont(ofSize: 14)
    label.textColor = .lightGray
    label.translatesAutoresizingMaskIntoConstraints = false
    label.tag = 401
    return label
  }()

  // MARK: - Init

  override init(frame: CGRect) {
    super.init(frame: frame)

    let profileImageDimension: CGFloat = 60

    addSubview(settingsImageView)
    settingsImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    settingsImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 16).isActive = true
    settingsImageView.widthAnchor.constraint(equalToConstant: profileImageDimension).isActive = true
    settingsImageView.heightAnchor.constraint(equalToConstant: profileImageDimension).isActive = true
    settingsImageView.layer.cornerRadius = profileImageDimension / 2

    addSubview(settingsViewLabel)
    settingsViewLabel.centerYAnchor.constraint(equalTo: settingsImageView.centerYAnchor, constant: -10)
      .isActive = true
    settingsViewLabel.leftAnchor.constraint(equalTo: settingsImageView.rightAnchor, constant: 12).isActive = true

    addSubview(settingsViewSubLabel)
    settingsViewSubLabel.centerYAnchor.constraint(equalTo: settingsImageView.centerYAnchor, constant: 10)
      .isActive = true
    settingsViewSubLabel.leftAnchor.constraint(equalTo: settingsImageView.rightAnchor, constant: 12).isActive = true
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

}
