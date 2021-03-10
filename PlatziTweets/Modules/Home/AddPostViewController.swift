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
import AVFoundation
import AVKit
import MobileCoreServices

class AddPostViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var postTextView: UITextView!
    @IBOutlet weak var previewImageView: UIImageView!
    @IBOutlet weak var videoButton: UIButton!
    
    // MARK: - IBActions
    @IBAction func openCameraAction() {
        
        let alert = UIAlertController(title: "Cámara",
                                      message: "selecciona una opcion",
                                      preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "photo", style: .default, handler: { _ in
            self.openCamera()
        }))
        alert.addAction(UIAlertAction(title: "video", style: .default, handler: { _ in
            self.openVideoCamera()
        }))
        alert.addAction(UIAlertAction(title: "cancelar", style: .destructive, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func addPostAction() {
        
        // aqui no puedes agregar un tweet sin un video entonces o juntas las dos funciones o
        // creas un if condition que corra cierta funcion de acuerdo a si el usuario publica un tweet
        // con imagen, solo o con video.
        
        //savePost(imageUrl: nil, videoUrl: nil)
        uploadVideoToFirebase()
        //uploadPhotoToFirebase()
    }

    @IBAction func openVideoCameraAction(){
        
        guard let currentVideoUrl = currentVideoUrl else {
            return
        }
        let avPlayer = AVPlayer(url: currentVideoUrl)
        
        let avPlayerController = AVPlayerViewController()
        avPlayerController.player = avPlayer
        
        present(avPlayerController, animated: true) {
            avPlayerController.player?.play()
        }
    }
    
    @IBAction func dismissAction() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Properties
    private var imagePicker: UIImagePickerController?
    private var currentVideoUrl: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        videoButton.isHidden = true
    }
    
    
    // MARK: - Private methods
    private func openVideoCamera() {
        imagePicker = UIImagePickerController()
        imagePicker?.sourceType = .camera
        imagePicker?.mediaTypes = [kUTTypeMovie as String]
        imagePicker?.cameraFlashMode = .off
        imagePicker?.cameraCaptureMode = .video
        imagePicker?.videoQuality = .typeMedium
        imagePicker?.videoMaximumDuration = TimeInterval(5)
        imagePicker?.allowsEditing = true
        imagePicker?.delegate = self
        
        guard let imagePicker = imagePicker else {
            return
        }
        
        present(imagePicker, animated: true, completion: nil)
    }
    
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
    
    // try to make this two next func into just one in the future
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
                        self.savePost(imageUrl: downloadUrl, videoUrl: nil)
                    }
                }
            }
        }
    }
    
    private func uploadVideoToFirebase() {
        // 1. be sure the videoexists
        // 2. to convert in data the video
        guard
            let currentVideoSavedUrl = currentVideoUrl,
            let videoData: Data = try? Data(contentsOf: currentVideoSavedUrl) else {
            
            return
        }
        
        SVProgressHUD.show()
        
        // 3. video storage settings
        let metaDataConfig = StorageMetadata()
        metaDataConfig.contentType = "video/MP4"
        
        // 4. referencia a storage de firebase
        let storage = Storage.storage()
        
        // 5. crear nombre del video a subir
        let videoName = Int.random(in: 100...1000)
        
        // 6. crear referencia al folder destino del video
        let folderReference = storage.reference(withPath: "video-tweets\(videoName).mp4")
        
        // 7 subir video a firebase yendo a hilo secundario con dispatchqueue
        DispatchQueue.global(qos: .background).async {
            folderReference.putData(videoData, metadata: metaDataConfig) { (metadata: StorageMetadata?, error: Error?) in
                
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
                        self.savePost(imageUrl: nil, videoUrl: downloadUrl)
                    }
                }
            }
        }
    }
    
    private func savePost(imageUrl: String?, videoUrl: String?) {
        
        guard let _ = postTextView.text, postTextView.hasText else {
            NotificationBanner(title: "Error", subtitle: "Debes escribir un Tweet", style: BannerStyle.warning).show()
            
            return
        }
        // 1. Crear request
        let request = PostRequest(text: postTextView.text, imageUrl: imageUrl, videoUrl: videoUrl, location: nil)
        
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
                
            case .error(let error):
                NotificationBanner(title: "Error",
                                   subtitle: error.localizedDescription,
                                   style: .danger).show()
                
            case .errorResult(let entity):
                NotificationBanner(title: "Error",
                                   subtitle: entity.error,
                                   style: .warning).show()
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
        
        // obtener url del video
        if info.keys.contains(.mediaURL), let recordedVideoUrl = (info[.mediaURL] as? URL)?.absoluteURL {
            videoButton.isHidden = false
            currentVideoUrl = recordedVideoUrl
        }
    }
}
