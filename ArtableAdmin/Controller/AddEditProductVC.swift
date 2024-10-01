//
//  AddEditProductVC.swift
//  ArtableAdmin
//
//  Created by Anup Saud on 2024-09-28.
//

import UIKit
import FirebaseStorage
import FirebaseFirestore

class AddEditProductVC: UIViewController {
    var productToEdit: Product?
    var selectedCategory: Category!
    
    //outlets
    
    @IBOutlet weak var productNameText: UITextField!
    @IBOutlet weak var productPrice: UITextField!
    
    @IBOutlet weak var addProductButton: RoundedButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var productImage: RoundedImageView!
    @IBOutlet weak var productDescText: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let tap = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
        tap.numberOfTapsRequired = 1
        productImage.isUserInteractionEnabled = true
        productImage.addGestureRecognizer(tap)
    }
    @objc func imageTapped(_ tap:UITapGestureRecognizer){
        lunchImage()
    }
    

    @IBAction func addEditProductButtonClicked(_ sender: Any) {
        uploadImageThenDocument()
    }

    func uploadImageThenDocument(){
        guard let image = productImage.image , let name = productNameText.text , let productPrice = productPrice.text, let productDescription = productDescText.text else {
            simpleAlert(title: "Error", msg: "Must add Product name, Product price, Product image and Product Description.")
            return
        }
        //get the image data
        guard let imageData = image.jpegData(compressionQuality: 0.2) else {
            return
        }
        //create image ref in firebase storage
        let imageRef = Storage.storage().reference().child("/productImages\(name).jpg")
        //set metaData
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        
        //upload image into firebase storage
        imageRef.putData(imageData, metadata: metaData) { metaData, error in
            if let error = error {
                self.handleError(error: error, msg: "Unable to upload image")
            }
            // the image is uploaded, retrieve its download URL
            imageRef.downloadURL { url, error in
                if let error = error{
                    self.handleError(error: error, msg: "Unale to retriver image URL")
                }
                guard let url = url else {return}
                // Upload the category document to Firestore with the image URL
                print(url)
               // uploadDocument(url: url.absoluteString)
            }
            
        }
        func uploadDocument(url: String){
            
        }
    }
        func handleError(error: Error, msg: String) {
            // Print the error description to the console for debugging purposes
            debugPrint(error.localizedDescription)
            
            // Display a simple alert to the user with the provided message
            self.simpleAlert(title: "Error", msg: msg)
            
            // Stop the activity indicator to signify the end of the upload process
            self.activityIndicator.stopAnimating()
            
            // Return to ensure that no further code execution happens after the error is handled
            return
        }

}
extension AddEditProductVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func lunchImage(){
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else {
            return
        }
        productImage.contentMode = .scaleAspectFill
        productImage.image = image
        dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
