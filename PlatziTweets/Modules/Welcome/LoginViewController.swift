//
//  LoginViewController.swift
//  PlatziTweets
//
//  Created by Nick Rodriguez Nova on 23/02/21.
//

import UIKit
import NotificationBannerSwift
import Simple_Networking
import SVProgressHUD


class LoginViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    // MARK: - IBActions
    @IBAction func loginButtonAction() {
        
        let email = emailTextField.text
            
        storage.set(email, forKey: emailKey)
        
        
        view.endEditing(true)
        performLogin()
    }
    
    private let emailKey = "email"
    private let storage = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let storedEmail = storage.string(forKey: emailKey) {
            emailTextField.text = storedEmail
        }
        
        setupUI()
    }
    
    // MARK: - Private Methods
    private func setupUI() {
        loginButton.layer.cornerRadius = 20
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
        
        // crear request mandando email y password dados por el user
        let request = LoginRequest(email: email, password: password)
        
        // iniciar la carga llamando a libreria SVP
        SVProgressHUD.show()
        
        // llamar a libreria de red Simple_Networking
        SN.post(endpoint: Endpoints.login, model: request) { (response: SNResultWithEntity<LoginResponse, ErrorResponse>) in
            
            SVProgressHUD.dismiss()
            
            switch response {
            case . success(let user):
                NotificationBanner(subtitle: "Welcome \(user.user.names)", style: BannerStyle.success).show()
                self.performSegue(withIdentifier: "showHome", sender: nil)
                SimpleNetworking.setAuthenticationHeader(prefix: "", token: user.token)
                
            case .error( _):
                NotificationBanner(subtitle: "Error inesperado", style: BannerStyle.danger).show()
                
            case .errorResult( _):
                NotificationBanner(subtitle: "Verifica tus credenciales y vuelve a intentar", style: BannerStyle.danger).show()
            }
        }
    }
}

