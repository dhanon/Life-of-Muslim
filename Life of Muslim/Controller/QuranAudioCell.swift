//
//  QuranAudioCell.swift
//  Life of Muslim
//
//  Created by Anon's MacBook Pro on 21/10/22.
//
import UIKit

class QuranAudioCell: UITableViewCell {
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var arabicNameLbl: UILabel!
    @IBOutlet weak var audioPlayButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

