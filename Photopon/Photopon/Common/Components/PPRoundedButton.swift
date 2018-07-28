//
//  PPRoundedButton.swift
//  Photopon
//
//  Created by Damien Rottemberg on 5/1/18.
//  Copyright © 2018 Photopon. All rights reserved.
//

import UIKit

@IBDesignable
class PPRoundedButton: UIButton {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    
    func setup(){
        
        self.layer.cornerRadius = 8
        self.layer.masksToBounds = true
        
    }
}
