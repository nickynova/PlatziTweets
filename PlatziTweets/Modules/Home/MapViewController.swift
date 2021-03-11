//
//  MapViewController.swift
//  PlatziTweets
//
//  Created by Nick Rodriguez Nova on 11/03/21.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var mapContainer: UIView!
    
    // MARK: - Properties
    var posts = [Post]()
    private var map: MKMapView?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setupMap()
    }
    
    private func setupMap() {
        map = MKMapView(frame: mapContainer.bounds)
        
        mapContainer.addSubview(map ?? UIView())
        
        setupMarkers()
    }
    
    private func setupMarkers() {
        posts.forEach { item in
            let marker = MKPointAnnotation()
            marker.coordinate = CLLocationCoordinate2D(latitude: item.location.latitude, longitude: item.location.longitude)
            
            marker.title = item.text
            marker.subtitle = item.author.names
            
            map?.addAnnotation(marker)
        }
        
        guard let firstPost = posts.first else {
            return
        }
        
        let userPostLocation = CLLocationCoordinate2D(latitude: firstPost.location.latitude,
                                                      longitude: firstPost.location.longitude)
        
        guard let heading = CLLocationDirection(exactly: 4) else {
            return
        }
        
        map?.camera = MKMapCamera(lookingAtCenter:
                                userPostLocation, fromDistance: 30,
                                pitch: .zero,
                                heading: heading)
    }
}
