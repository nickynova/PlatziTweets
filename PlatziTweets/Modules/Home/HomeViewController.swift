//
//  HomeViewController.swift
//  PlatziTweets
//
//  Created by Nick Rodriguez Nova on 1/03/21.
//

import UIKit
import Simple_Networking
import SVProgressHUD
import NotificationBannerSwift
import AVKit

class HomeViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    private let cellId = "TweetTableViewCell"
    private var dataSource = [Post]()
    private let emailKey = "email"
    private let defaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getPosts()
    }
    
    // MARK: - Private methods
    private func setupUI() {
        // para darle vida a la tabla:
        // 1. Asignar dataSource
        // 2. registrar celda
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: cellId, bundle: nil), forCellReuseIdentifier: cellId)
    }
    
    private func getPosts() {
        // 1. indicar carga
        SVProgressHUD.show()
        
        //2. consumir servicio
        SN.get(endpoint: Endpoints.getPosts) { (response: SNResultWithEntity<[Post], ErrorResponse>) in
            
            SVProgressHUD.dismiss()
            
            switch response {
            case . success(let posts):
                self.dataSource = posts
                self.tableView.reloadData()
                
            case .error( _):
                NotificationBanner(subtitle: "Error inesperado", style: BannerStyle.danger).show()
                
            case .errorResult( _):
                NotificationBanner(subtitle: "Verifica tus credenciales y vuelve a intentar", style: BannerStyle.danger).show()
            }
        }
    }
    
    private func deletePostA(indexPath: IndexPath) {
        // borrar tweets paso a paso del metodo que contiene la logica
        // 1. Indicar carga
        SVProgressHUD.show()
        
        // 2. get ID del post a borrar
        let postId = dataSource[indexPath.row].id
        
        // 3. preparamos endpoint para borrar
        let endpoint = Endpoints.delete + postId
        
        // 4. consumir servicio
        SN.delete(endpoint: endpoint) { (response: SNResultWithEntity<GeneralResponse, ErrorResponse>) in
            
            SVProgressHUD.dismiss()
            
            switch response {
            case . success:
                // 1. borrar post del datasource y 2. la celda de la tabla
                self.defaults.setValue(self.dataSource[indexPath.row].author.email, forKey: self.emailKey)
                self.dataSource.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .left)
                
            case .error( _):
                NotificationBanner(subtitle: "Error inesperado", style: BannerStyle.danger).show()
                
            case .errorResult( _):
                NotificationBanner(subtitle: "Verifica tus credenciales y vuelve a intentar", style: BannerStyle.danger).show()
            }
        }
    }
}

// MARK: - UITableViewDelegate
extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let deleteAction = UITableViewRowAction(style: .destructive, title: "borrar") { (_, _) in
            self.deletePostA(indexPath: indexPath)
        }
        
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        let storedEmail = defaults.string(forKey: emailKey)
        
        return dataSource[indexPath.row].author.email == storedEmail
    }
}

// MARK: - UITableViewDataSource
extension HomeViewController: UITableViewDataSource {
    // Numero total de celdas
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return dataSource.count
    }
    
    //Configurar celda deseada
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        if let cell = cell as? TweetTableViewCell {
            // configurar celda
            cell.setupCellWith(post: dataSource[indexPath.row])
            cell.needsToShowVideo = { url in
                // esta func viene del tableViewCell y se abre aqui un viewcontroller por buena practica
                let avPlayer = AVPlayer(url: url)
                
                let avPlayerController = AVPlayerViewController()
                avPlayerController.player = avPlayer
                
                self.present(avPlayerController, animated: true) {
                    avPlayerController.player?.play()
                }
            }
        }
        
        return cell
    }
}
