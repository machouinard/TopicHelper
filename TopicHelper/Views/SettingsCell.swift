//
//  SettingsCell.swift
//  TopicHelper
//
//  Created by Mark Chouinard on 10/6/19.
//  Copyright © 2019 Mark Chouinard. All rights reserved.
//

import UIKit

class SettingsCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    var sectionType: SectionType? {
        didSet {
            guard let sectionType = sectionType else {
                return
            }
            textLabel?.text = sectionType.description
            if let details = sectionType.detailText {
                detailTextLabel?.text = details
            }
            
            switchControl.isHidden = !sectionType.containsSwitch
        }
    }
    
    lazy var switchControl: UISwitch = {
        let switchControl = UISwitch()
        switchControl.isOn = true
        switchControl.onTintColor = .systemBlue
        switchControl.translatesAutoresizingMaskIntoConstraints = false
        switchControl.addTarget(self, action: #selector(handleSwitchAction), for: .valueChanged)
        
        return switchControl
    }()
    
    @objc func handleSwitchAction(sender: UISwitch) {
        if sender.isOn {
            
            print("Switch On")
        } else {
            print("Switch Off")
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        
        
        addSubview(switchControl)
        switchControl.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        switchControl.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -12).isActive = true
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    

}
