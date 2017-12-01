//
//  SelfieViewController.swift
//  FotoMap
//
//  Created by Alumno ITESM Toluca on 08/11/17.
//  Copyright © 2017 Alumno ITESM Toluca. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class SelfieViewController : UIViewController, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, CLLocationManagerDelegate{
    @IBOutlet weak var tvLon: UILabel!
    @IBOutlet weak var tvLat: UILabel!
    @IBOutlet weak var ivFoto: UIImageView!
    
    @IBOutlet weak var tfTexto: UITextField!
    
    @IBOutlet weak var bGuardar: UIBarButtonItem!
    
    var url:String?
    
    var selfie:Selfie?
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tfTexto.delegate = self
        
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled(){
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let ubicacion = manager.location?.coordinate
        
        tvLon.text = String(ubicacion!.longitude)
        tvLat.text = String(ubicacion!.latitude)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        tfTexto.resignFirstResponder()
        
        return true
    }
    
    @IBAction func cancelarView(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cargarGaleria(_ sender: Any) {
        let galeria = UIImagePickerController()
        galeria.sourceType = .photoLibrary
        galeria.delegate = self
        present(galeria, animated:true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let imagenSeleccinada = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            fatalError("Error al cargar la imagen")
        }
        
        dismiss(animated: true, completion: nil)
        
        if(validarCara(imagen: imagenSeleccinada)) {
            ivFoto.image = imagenSeleccinada
        } else {
            mostrarAlerta(mensaje: "Esa no se una selfie")
        }
        
    }
    
    func mostrarAlerta(mensaje:String){
        let alerta = UIAlertController(title: "Error", message: mensaje, preferredStyle: .alert)
        alerta.addAction(UIAlertAction.init(title:"Ok", style:.default, handler: nil))
        present(alerta, animated: true, completion: nil)
    }
    
    func validarCara(imagen: UIImage) -> Bool{
        let ciImage = CIImage(image: imagen)
        let detector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: [CIDetectorAccuracy : CIDetectorAccuracyHigh])
        
        let rostros = detector?.features(in: ciImage!) as! [CIFaceFeature]
        
        if rostros.count > 0{
            print("Es una selfie")
            return true
        }
        
        print("no es una selfie")
        
        return false
    }
    
    func subirInfo(selfie: Selfie){
        let url = URL(string: "http://appmysql01.azurewebsites.net/index.php")!
        var request = URLRequest(url: url)
        
        if let imagenData = UIImageJPEGRepresentation(ivFoto.image!, 0.6){
            let imagenCodificada = imagenData.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
            
            request.httpMethod = "POST"
            
            let postString = "image=\(imagenCodificada)&texto=\(selfie.nombre)&latitud=\(selfie.latitud)&longitud=\(selfie.longitud)&imagename=\(selfie.fotoURL)"
            
            request.httpBody = postString.data(using: .utf8)
            
            let task = URLSession.shared.dataTask(with: request){ data, response, error in
                guard let data = data, error == nil else {
                    print("error")
                    return
                }
                
                let response = String(data: data, encoding: .utf8)
                print("Respuesta: \(response ?? "")")
            }
            
            task.resume()
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard let guardar = sender as? UIBarButtonItem, guardar === bGuardar else {
            fatalError("Error de boton")
        }
        
        // Creacion de nueva selfie
        
        let texto = tfTexto.text ?? ""
        let lon = tvLon.text ?? ""
        let lat = tvLat.text ?? ""
        
        selfie = Selfie(nombre: texto, fotoURL: generarNombre(), latitud: lat, longitud: lon, image: ivFoto.image!)
                
        subirInfo(selfie: selfie!)
    }
    
    func generarNombre() -> String {
        let date = Date()
        let formato = DateFormatter()
        formato.dateFormat = "ssmmhhddmmyyyy"
        
        return formato.string(from: date)
    }
}
