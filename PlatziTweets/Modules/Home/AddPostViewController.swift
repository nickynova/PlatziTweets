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
import FirebaseStorage

class AddPostViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var postTextView: UITextView!
    @IBOutlet weak var previewImageView: UIImageView!
    
    // MARK: - IBActions
    @IBAction func openCameraAction() {
        openCamera()
    }
    
    @IBAction func addPostAction() {
        uploadPhotoToFirebase()
    }
    
    @IBAction func dismissAction() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Properties
    private var imagePicker: UIImagePickerController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    // MARK: - Private methods
    private func openCamera() {
        imagePicker = UIImagePickerController()
        imagePicker?.sourceType = .camera
        imagePicker?.cameraFlashMode = .auto
        imagePicker?.cameraCaptureMode = .photo
        imagePicker?.allowsEditing = true
        imagePicker?.delegate = self
        
        guard let imagePicker = imagePicker else {
            return
        }
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    private func uploadPhotoToFirebase() {
        // 1. be sure the photo exists
        // 2. to compress the image
        guard
            let imageSaved = previewImageView.image,
            let imageSavedData: Data = imageSaved.jpegData(compressionQuality: 0.1) else {
            
            return
        }
        
        SVProgressHUD.show()
        
        // 3. photo storage settings
        let metaDataConfig = StorageMetadata()
        metaDataConfig.contentType = "image/jpg"
        
        // 4. referencia a storage de firebase
        let storage = Storage.storage()
        
        // 5. crear nombre de la imagen a subir
        let imagename = Int.random(in: 100...1000)
        
        // 6. crear referencia al folder destino de la photo
        let folderReference = storage.reference(withPath: "tweet-photos\(imagename).jpg")
        
        // 7 subir foto a firebase yendo a hilo secundario con dispatchqueue
        DispatchQueue.global(qos: .background).async {
            folderReference.putData(imageSavedData, metadata: metaDataConfig) { (metadata: StorageMetadata?, error: Error?) in
                
                DispatchQueue.main.async {
                    
                    // 8. ir a hilo principal y detener carga y verfificar error
                    SVProgressHUD.dismiss()
                    
                    if let error = error {
                        NotificationBanner(subtitle: error.localizedDescription, style: BannerStyle.danger).show()
                        
                        return
                    }
                    
                    //9. si no hay error obtener url de descarga
                    folderReference.downloadURL { (url: URL?, error: Error?) in
                        let downloadUrl = url?.absoluteString ?? ""
                        self.savePost(imageUrl: downloadUrl)
                    }
                }
            }
        }
    }
    
    private func savePost(imageUrl: String?) {
        
        guard let _ = postTextView.text, postTextView.hasText else {
            NotificationBanner(title: "Error", subtitle: "Debes escribir un Tweet", style: BannerStyle.warning).show()
            
            return
        }
        // 1. Crear request
        let request = PostRequest(text: postTextView.text, imageUrl: imageUrl, videourl: nil, location: nil)
        
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

// MARK: - UIImagePickerControllerDelegate
extension AddPostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // cerrar camera
        imagePicker?.dismiss(animated: true, completion: nil)
        
        //obtener imagen
        if info.keys.contains(.originalImage) {
            previewImageView.isHidden = false
            previewImageView.image = info[.originalImage] as? UIImage
        }
    }
}
