//
//  SelfieMapaViewController.swift
//  FotoMap
//
//  Created by Alumno ITESM Toluca on 15/11/17.
//  Copyright © 2017 Alumno ITESM Toluca. All rights reserved.
//

import UIKit
import MapKit

class SelfieMapaViewController: UIViewController, MKMapViewDelegate {

    var selfies = [Selfie]()
    var selfie: Selfie?
    
    @IBOutlet weak var mapa: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let distancia: CLLocationDegrees = 1000
        // ubicacion de selfie seleccionada
        let ubicacion = CLLocationCoordinate2DMake(Double((selfie?.latitud)!)!, Double((selfie?.longitud)!)!)
        
        mapa.delegate = self
        
        mapa.setRegion(MKCoordinateRegionMakeWithDistance(ubicacion, distancia, distancia), animated: true)
        
        for item in selfies{
            let location = CLLocationCoordinate2DMake(Double(item.latitud)!, Double(item.longitud)!)
            let pin = Pin(title: item.nombre, coordinate:location)
            
            mapa.addAnnotation(pin)
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
