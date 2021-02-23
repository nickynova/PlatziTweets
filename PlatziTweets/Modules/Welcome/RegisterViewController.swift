//
//  RegisterViewController.swift
//  PlatziTweets
//
//  Created by Nick Rodriguez Nova on 23/02/21.
//

import UIKit
import NotificationBannerSwift

class RegisterViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var nameAndLastname: UITextField!
    
    // MARK: - IBActions
    @IBAction func createAccountButtonAction() {
        performLogin()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    private func setupUI() {
        registerButton.layer.cornerRadius = 24
    }
    
    private func performLogin() {
        guard let email = emailTextField.text, !email.isEmpty else {
            NotificationBanner(title: "Error", subtitle: "Debes especificar un correo", style: BannerStyle.warning).show()
            
            return
        }
        guard let password = passwordTextField.text, !password.isEmpty else {
            NotificationBanner(title: "Error", subtitle: "Debes especificar una contrasenia", style: BannerStyle.warning).show()
            
            return
        }
        guard let nameAndLastname = nameAndLastname.text, !nameAndLastname.isEmpty else {
            NotificationBanner(title: "Error", subtitle: "Debes especificar un nombre y apellido", style: BannerStyle.warning).show()
            
            return
        }
    }
}
