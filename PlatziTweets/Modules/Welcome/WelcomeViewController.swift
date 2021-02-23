//
//  WelcomeViewController.swift
//  PlatziTweets
//
//  Created by Nick Rodriguez Nova on 23/02/21.
//

import UIKit

class WelcomeViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet weak var loginButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    private func setupUI() {
        loginButton.layer.cornerRadius = 24
    }
}
