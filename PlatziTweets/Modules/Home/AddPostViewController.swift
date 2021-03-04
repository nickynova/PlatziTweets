//
//  AddPostViewController.swift
//  PlatziTweets
//
//  Created by Nick Rodriguez Nova on 3/03/21.
//

import UIKit
import Simple_Networking
import SVProgressHUD
import NotificationBannerSwift

class AddPostViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var postTextView: UITextView!
    
    // MARK: - IBActions
    @IBAction func addPostAction() {
        savePost()
    }
    @IBAction func dismissAction() {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    // MARK: - Private methods
    private func savePost() {
        
        guard let _ = postTextView.text, postTextView.hasText else {
            NotificationBanner(title: "Error", subtitle: "Debes escribir un Tweet", style: BannerStyle.warning).show()
            
            return
        }
        // 1. Crear request
        let request = PostRequest(text: postTextView.text, imageUrl: nil, videourl: nil, location: nil)
        
        // 2. Avisar carga
        SVProgressHUD.show()
        
        // 3. Llamar al servicio
        SN.post(endpoint: Endpoints.post, model: request) { (response: SNResultWithEntity<Post, ErrorResponse>) in
            
            // 4. Cerrar indicador de carga
            SVProgressHUD.dismiss()
            
            // 5. Logica
            switch response {
            case . success:
                self.dismiss(animated: true, completion: nil)
                
            case .error( _):
                NotificationBanner(subtitle: "Error inesperado", style: BannerStyle.danger).show()
                
            case .errorResult( _):
                NotificationBanner(subtitle: "Verifica tus credenciales y vuelve a intentar", style: BannerStyle.danger).show()
            }
        }
    }
}
