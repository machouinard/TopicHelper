//
//  FavoriteButton.swift
//  TopicHelper
//
//  Created by Mark Chouinard on 10/5/19.
//  Copyright © 2019 Mark Chouinard. All rights reserved.
//

import UIKit

class FavoriteButton: UIButton {
    
    

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let area: CGRect = CGRect(x: self.bounds.origin.x - 10, y: self.bounds.origin.y - 10, width: self.bounds.size.width + 10, height: self.bounds.size.height + 10)
        
        return area.contains(point)
        
    }

}
