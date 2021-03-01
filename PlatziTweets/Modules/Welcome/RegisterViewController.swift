//
//  RegisterViewController.swift
//  PlatziTweets
//
//  Created by Nick Rodriguez Nova on 23/02/21.
//

import UIKit
import NotificationBannerSwift
import Simple_Networking
import SVProgressHUD

class RegisterViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var nameAndLastname: UITextField!
    
    // MARK: - IBActions
    @IBAction func createAccountButtonAction() {
        view.endEditing(true)
        performRegister()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    // MARK: - Private Methods
    private func setupUI() {
        registerButton.layer.cornerRadius = 20
    }
    
    private func performRegister() {
        guard let email = emailTextField.text, !email.isEmpty else {
            NotificationBanner(title: "Error", subtitle: "Debes especificar un correo", style: BannerStyle.warning).show()
            
            return
        }
        guard let emailTypeVerification = emailTextField.text, emailTypeVerification.contains(_: "@") else {
            NotificationBanner(title: "Error", subtitle: "Debes especificar un correo válido", style: BannerStyle.warning).show()
            
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
        
        // se crea el request
        let request = ResgisterRequest(email: email, password: password, names: nameAndLastname)
        
        // se muestra carga al usuario
        SVProgressHUD.show()
        
        // llamar al servicio
        SN.post(endpoint: Endpoints.register, model: request) { (response: SNResultWithEntity<LoginResponse, ErrorResponse>) in
            
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

