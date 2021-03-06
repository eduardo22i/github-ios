//
//  EventsViewController.swift
//  GitHub iOS
//
//  Created by Eduardo Irias on 11/7/17.
//  Copyright © 2017 Estamp. All rights reserved.
//

import UIKit

class EventsViewController: UIViewController {

    var events = [Event]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    @IBOutlet weak var tableView : UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        }
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        self.tableView.estimatedRowHeight = 100
        
        if let user = User.current {
            DataManager.shared.getEvents(user: user) { (events, error) in
                self.events = events ?? []
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        for indexPath in tableView.indexPathsForSelectedRows ?? [] {
            tableView.deselectRow(at: indexPath, animated: false)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Navigation

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        let event = events[tableView.indexPathForSelectedRow?.row ?? 0]
        if event.repo == nil || event.repo?.owner == nil {
            return false
        }
        return true
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let vc = segue.destination as? RepoViewController {
            let event = events[tableView.indexPathForSelectedRow?.row ?? 0]
            vc.repo = event.repo
        }
    }

}

extension EventsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell") as! EventTableViewCell
        
        let event = events[indexPath.row]
        
        let username = event.actor?.username ?? ""
        let repo = (event.repo?.owner?.username ?? "") + "/" + (event.repo?.name ?? "")
        let description = String(format: event.type!.description, username,  repo)
        
        cell.descriptionLabel?.text = description
        
        cell.avatarImageView.image = #imageLiteral(resourceName: "Oct Icon")
        event.actor?.fetchImageIfNeeded({ (data, error) in
            if let data = data {
                cell.avatarImageView.image = UIImage(data: data)
            }
        })
        
        return cell
    }
    
}
