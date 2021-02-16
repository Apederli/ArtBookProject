//
//  DetailViewController.swift
//  ArtBookProject
//
//  Created by aydoğan pederli on 2.02.2021.
//

import UIKit
import CoreData

class DetailViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    @IBOutlet weak var imageLayer: UIImageView!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var artText: UITextField!
    @IBOutlet weak var yearText: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    
    var chosenPainting = ""
    var chosenPaintingId : UUID?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if chosenPainting != "" {
         
            saveButton.isHidden=true
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchReguest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
            
            let idString = chosenPaintingId?.uuidString
            
            fetchReguest.predicate = NSPredicate(format: "id = %@", idString!)
            
            fetchReguest.returnsObjectsAsFaults=false
            
            do {
                let results =  try context.fetch(fetchReguest)
                if results.count > 0 {
                    for result in results as! [NSManagedObject] {
                        if let name = result.value(forKey: "name") as? String{
                            nameText.text=name
                        }
                        
                        if let artist = result.value(forKey: "artist") as? String{
                            artText.text = artist
                        }
                        
                        if let year = result.value(forKey: "year") as? Int{
                            yearText.text = String(year)
                        }
                        
                        if let imageData = result.value(forKey: "image") as? Data{
                            let image = UIImage(data: imageData)
                            imageLayer.image = image
                        }
                    }
                }
            } catch  {
                print("error")
            }
        }else{
            saveButton.isHidden=false
            saveButton.isEnabled=false
        }
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeybord))
        view.addGestureRecognizer(gestureRecognizer)
        
        imageLayer.isUserInteractionEnabled=true
        
        let imageTapRegonizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        
        imageLayer.addGestureRecognizer(imageTapRegonizer)
        
    }
    
    
    
    @IBAction func saveButton(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let context = appDelegate.persistentContainer.viewContext
        
        let newPainting = NSEntityDescription.insertNewObject(forEntityName: "Paintings", into: context)
        
        newPainting.setValue(nameText.text!, forKey: "name")
        
        newPainting.setValue(artText.text!, forKey: "artist")
        
        if let year = Int(yearText.text!){
            newPainting.setValue(year, forKey: "year")
        }
        
        newPainting.setValue(UUID(), forKey: "id")
        
        let data = imageLayer.image!.jpegData(compressionQuality: 0.5)
        
        newPainting.setValue(data, forKey: "image")
        
        do {
            try context.save()
            print("success")
        } catch  {
            print("error")
        }
        
        
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
        
        // Bir önceki ViewControllera Gider
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @objc func selectImage(){
        
        let picker = UIImagePickerController()
        
        picker.delegate = self
        
        picker.sourceType = .photoLibrary
        
        picker.allowsEditing = true
        
        present(picker, animated: true, completion: nil)
        
    }
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    
        imageLayer.image = info[.originalImage] as? UIImage
        saveButton.isEnabled=true
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @objc func hideKeybord() {
        view.endEditing(true)
    }
    
    
}
