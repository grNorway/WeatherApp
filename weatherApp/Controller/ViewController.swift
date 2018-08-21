//
//  ViewController.swift
//  weatherApp
//
//  Created by PS Shortcut on 21/08/2018.
//  Copyright © 2018 PS Shortcut. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    
    //MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        ApixuClient.shared.getCurrentWeather(location: "oslo") { (success, results, error) in
            
            if success {
                print(results)
            }else{
                print(results)
            }
            
        }
        
    }

    


}

extension ViewController : UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    
}

extension ViewController : UITableViewDelegate {
    
}

