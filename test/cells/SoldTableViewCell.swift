//
//  SoldTableViewCell.swift
//  BirdsApp
//
//  Created by MacBook Pro on 20/12/2023.
//

import UIKit

class SoldTableViewCell: UITableViewCell {
    
    @IBOutlet weak var certificateNo: UILabel!
    
    @IBOutlet weak var soldDateLbl: UILabel!
    @IBOutlet weak var birdIdLbl: UILabel!
    
    @IBOutlet weak var birdSpecieLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
