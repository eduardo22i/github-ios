//
//  RepoViewController.swift
//  GitHub User Profile
//
//  Created by Eduardo Irías on 8/16/15.
//  Copyright (c) 2015 Estamp World. All rights reserved.
//

import UIKit

class RepoViewController: UIViewController, RepoDetailPartDelegate {

    var user : User!
    var repo : Repo!
    var commits : [Commit] = [] {
        didSet {
            let plusString = self.commits.count >= 100 ? "+" : ""
            self.commitsButton.setTitle("\(self.commits.count)\(plusString) Commits", for: .normal)
        }
    }
    
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var branchLabel: UILabel!
    @IBOutlet weak var commitsButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = repo.name
        
        self.descriptionTextView.text = repo.description
        self.branchLabel.text = repo.defaultBranch
        
        DataManager.getCommits(user.username, repo: repo.name, options: nil) { (records, error) -> Void in
            if let records = records as? [Commit] {
                self.commits = records
            }
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
        if segue.identifier == "showRepoBranchesSegue" {
            let vc = segue.destination as? RepoBranchesViewController
            vc?.repo = repo
            vc?.user = user
        } else if segue.identifier == "showRepoCommitsSegue" {
            let vc = segue.destination as? RepoCommitsViewController
            vc?.repo = repo
            //vc?.user = user
            vc?.commits = commits
        }
    }

    
    @IBAction func viewOnGitHubAction (_ sender : AnyObject!) {
        
        // Allow user to choose between photo library and camera
        let alertController = UIAlertController(title: nil, message: "Do you want to open this address in Safari?", preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        
        let photoLibraryAction = UIAlertAction(title: "Open in Safari", style: .default) { (action) in
            
            if let url = self.repo.url {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        
        alertController.addAction(photoLibraryAction)
        
        self.present(alertController, animated: true, completion: nil)
       
    }
    
    
    //MARK: - RepoDetailPartDelegate
    func detailButtonClicked(_ segueIdentifier: String) {
        self.performSegue(withIdentifier: segueIdentifier, sender: self)

    }
}
