//
//  TableViewCell.swift
//  BirdsApp
//
//  Created by MacBook Pro on 15/12/2023.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet weak var certificateLbl: UILabel!
    
    @IBOutlet weak var birdIdLbl: UILabel!
    
    @IBOutlet weak var birdNameLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
