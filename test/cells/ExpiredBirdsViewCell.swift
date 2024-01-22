//
//  ExpiredBirdsViewCell.swift
//  BirdsApp
//
//  Created by MacBook Pro on 19/12/2023.
//

import UIKit

class ExpiredBirdsViewCell: UITableViewCell {

    @IBOutlet weak var certificateNoLbl: UILabel!
    
    @IBOutlet weak var birdIdLbl: UILabel!
    
    @IBOutlet weak var birdSpecieLbl: UILabel!
    
    @IBOutlet weak var expireDateLbl: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
