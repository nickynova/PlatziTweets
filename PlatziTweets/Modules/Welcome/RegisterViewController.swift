//
//  RegisterViewController.swift
//  PlatziTweets
//
//  Created by Nick Rodriguez Nova on 23/02/21.
//

import UIKit

class RegisterViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var registerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    private func setupUI() {
        registerButton.layer.cornerRadius = 24
    }
}
