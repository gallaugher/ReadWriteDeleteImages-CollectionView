//
//  ViewController.swift
//  SavingAndLoadingImages
//
//  Created by John Gallaugher on 4/24/17.
//  Copyright © 2017 Gallaugher. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    struct ImageAndURL {
        var image: UIImage!
        var url: String!
    }
    
    var structArray = [ImageAndURL]()
    
    var imagePicker = UIImagePickerController()
    let defaultsData = UserDefaults.standard
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        imagePicker.delegate = self
        
        readData()
    }
    
    func writeData(image: UIImage) {
        if let imageData = UIImagePNGRepresentation(image) {
            let fileName = NSUUID().uuidString // always creates unique string in part based on time/date
            let documents = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            let writePath = documents.appending(fileName)
            do {
                try imageData.write(to: URL(fileURLWithPath: writePath))
                structArray.append(ImageAndURL(image: image, url: fileName))
                let urlArray = structArray.map {$0.url}
                defaultsData.set(urlArray, forKey: "photoURLs")
            } catch {
                print("Error in trying to write imageData to imageURL = \(writePath)")
            }
            
        } else {
            print("Error in trying to convert image into data")
        }
        collectionView.reloadData()
    }
    
    
    func deleteData(index: Int) {
        let fileManager = FileManager.default
        let fileName = structArray[index].url
        let documents = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let deletePath = documents.appending(fileName!)
        do {
            try fileManager.removeItem(atPath: deletePath)
            structArray.remove(at: index)
            let urlArray = structArray.map {$0.url}
            defaultsData.set(urlArray, forKey: "photoURLs")
        } catch {
            print("Error in trying to delete imageData to imageURL = \(deletePath)")
        }
        
        collectionView.reloadData()
    }
    
    func getDirectoryPath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func readData() {
        if let urlArray = defaultsData.object(forKey: "photoURLs") as? [String] {
            
            for index in 0..<urlArray.count {
                
                let fileManager = FileManager.default
                let imagePath = getDirectoryPath() + urlArray[index]
                if fileManager.fileExists(atPath: imagePath) {
                    let newImage = UIImage(contentsOfFile: imagePath as String)
                    structArray.append(ImageAndURL(image: newImage, url: urlArray[index]))
                } else {
                    print("No Image")
                }
            }
            collectionView.reloadData()
        }
    }
    
    
    @IBAction func photoButtonPressed(_ sender: UIButton) {
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return structArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PhotoCollectionViewCell
        cell.photoImageView.image = structArray[indexPath.row].image
        return cell
    }
    
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var selectedImage: UIImage!
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImage = editedImage
        } else if let originalImage = info ["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImage = originalImage
        }
        
        dismiss(animated: true, completion: {self.writeData(image: selectedImage!)})
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let deleteAlert = UIAlertController(title: "Delete Image?", message: "", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Delete", style: .default, handler: { action in self.deleteData(index: indexPath.item)} )
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        deleteAlert.addAction(okAction)
        deleteAlert.addAction(cancelAction)
        
        let imageView = UIImageView(frame: CGRect(x: 5 , y: 5, width: 55, height: 55))
        imageView.image = structArray[indexPath.item].image
        deleteAlert.view.addSubview(imageView)
        
        present(deleteAlert, animated: true, completion: nil)
    }
}

