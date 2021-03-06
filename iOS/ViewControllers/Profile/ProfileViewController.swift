//
//  ProfileViewController.swift
//  GitHub iOS
//
//  Created by Eduardo Irias on 10/31/17.
//  Copyright © 2017 Estamp. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    var user : User? {
        didSet {
            self.navigationItem.title = user?.name
            tableView.reloadData()
        }
    }
    
    var organizations = [User.Organization]() {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    @IBOutlet var tableView : UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        }
        
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
        
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.estimatedRowHeight = 55
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.user = User.current
        
        guard let user = self.user else {
            self.performSegue(withIdentifier: "ShowLoginSegue", sender: self)
            return
        }
        
        DataManager.shared.getOrganizations(user: user) { (organizations, error) in
            self.organizations = organizations ?? []
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let vc = segue.destination as? UserViewController {
            
            let indexPath = (tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as! OrganizationsTableViewCell).collectionView.indexPath(for: sender as! UICollectionViewCell)
            vc.user = organizations[indexPath?.row ?? 0]            
        }
        
        if let vc = (segue.destination as? UINavigationController)?.topViewController as? LoginViewController {
            vc.delegate = self
        }
    }
    
}


// MARK: - UITableViewDataSource
extension ProfileViewController : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // Return the number of sections.
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        switch section {
        case 0:
            return user == nil ? 0 : 1
        case 1:
            return 1
        case 2:
            return user?.repos.count ?? 0
        default:
            return 0
        }
    }
    
    func cellIdentifier(indexPath: IndexPath) -> String {
        switch indexPath.section {
        case 0:
            return "UserInfoCell"
        case 1:
            return "OrganizationsCell"
        case 2:
            return "RepoCell"
        default:
            return ""
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Configure the cell...
        
        let identifier = cellIdentifier(indexPath: indexPath)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier)!
        
        if let cell = cell as? UserInfoTableViewCell {
            guard let user = user else {return cell}
            
            cell.usernameLabel.text = user.username
            cell.typeLabel.text = user.type?.rawValue
            if let user = user as? User.Individual {
                cell.companyLabel.text = user.company
            }
            cell.locationLabel.text = user.location
            cell.emailLabel.text = user.email
            cell.urlLabel.text = user.url
            
            cell.avatarImageView.image = #imageLiteral(resourceName: "Oct Icon")
            user.fetchImageIfNeeded({ (data, error) -> Void in
                guard let data = data else {
                    return
                }
                cell.avatarImageView.image = UIImage(data: data)
            })
            
        }
        
        if let cell = cell as? OrganizationsTableViewCell {
            cell.organizations = organizations
        }
        
        if let cell = cell as? RepoTableViewCell {
            
            let repo = user!.repos[indexPath.row ]
            cell.repoNameLabel.text = repo.name
            cell.starsLabel.text = "\(repo.stargazersCount)"
            
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}

extension ProfileViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
    }
    
}
extension ProfileViewController : LoginViewControllerDelegate {
    func loginViewController(_ loginViewController: LoginViewController, didLoginWith user: User) {
        self.user = user
        loginViewController.dismiss(animated: true)
    }
    
    func didCancel(_ loginViewController: LoginViewController) {
        loginViewController.dismiss(animated: true) {
            self.tabBarController?.selectedIndex = 0
        }
    }
    

}
