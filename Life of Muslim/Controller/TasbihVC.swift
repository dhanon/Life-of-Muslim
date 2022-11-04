//
//  TasbihVC.swift
//  Life of Muslim
//
//  Created by Anon's MacBook Pro on 17/10/22.
//

import UIKit

class TasbihVC: UIViewController {
    
    @IBOutlet weak var tasbihCountLbl: UILabel!
    var counter = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapAction)))
    }
    
    @objc func tapAction(_ gesture: UITapGestureRecognizer) {
        counter += 1
            tasbihCountLbl.text = String(counter)
    }
    
    @IBAction func newCountButton(_ sender: UIButton) {

        if (counter >= 0){
            counter = 0
            tasbihCountLbl.text = String(0)
        }
    }
    
    
    
}
