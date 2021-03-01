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

class HomeViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    private let cellId = "TweetTableViewCell"
    private var dataSource = [Post]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        getPosts()
        
    }
    
    // MARK: - Private methods
    private func setupUI() {
        // para darle vida a la tabla:
        // 1. Asignar dataSource
        // 2. registrar celda
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
        }
        
        return cell
    }
}
