//
//  HomeTabBarVC.swift
//  BirdsApp
//
//  Created by MacBook Pro on 01/01/2024.
//

import UIKit

class HomeTabBarVC: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        UserDefaults.standard.set(true, forKey: strLoginKey)


        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
