//
//  AddEditProductVC.swift
//  ArtableAdmin
//
//  Created by Anup Saud on 2024-09-28.
//

import UIKit
import FirebaseStorage
import FirebaseFirestore
import Kingfisher

class AddEditProductVC: UIViewController {
    var productToEdit: Product?
    var selectedCategory: Category!
    var name = ""
    var price = 0.0
    var productDescription = ""
    
    // outlets
    @IBOutlet weak var productNameText: UITextField!
    @IBOutlet weak var productPrice: UITextField!
    @IBOutlet weak var addProductButton: RoundedButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var productImage: RoundedImageView!
    @IBOutlet weak var productDescText: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Tap gesture recognizer for selecting an image
        let tap = UITapGestureRecognizer(target: self, action: #selector(imgTapped))
        tap.numberOfTapsRequired = 1
        productImage.isUserInteractionEnabled = true
        productImage.clipsToBounds = true
        productImage.addGestureRecognizer(tap)
        
        // Check if we're editing a product and load its image
        if let product = productToEdit {
            productNameText.text = product.name
            productDescText.text = product.productDescription
            productPrice.text = String(product.price)
            addProductButton.setTitle("Save Changes", for: .normal)
            
            if let url = URL(string: product.imageUrl) {
                productImage.contentMode = .scaleAspectFill
                productImage.kf.setImage(with: url)
            }
        }
    }

    @objc func imgTapped() {
        launchImagePicker()
    }

    @IBAction func addEditProductButtonClicked(_ sender: Any) {
        //activityIndicator.startAnimating()
        uploadImageThenDocument()
    }

    func uploadImageThenDocument() {
        // Validate the required fields
        guard let image = productImage.image,
              let name = productNameText.text, name.isNotEmpty,
              let productPrice = productPrice.text, let price = Double(productPrice),
              let productDescription = productDescText.text, productDescription.isNotEmpty else {
            simpleAlert(title: "Error", msg: "Must add Product name, price, image, and description.")
            return
        }

        self.name = name
        self.productDescription = productDescription
        self.price = price
        activityIndicator.startAnimating()
        // Get image data and compress it
        guard let imageData = image.jpegData(compressionQuality: 0.2) else {return}

        // Create a reference in Firebase Storage
        let imageRef = Storage.storage().reference().child("/ProductsImages/\(name).jpg")
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"

        // Upload the image to Firebase Storage
        imageRef.putData(imageData, metadata: metaData) { metaData, error in
            if let error = error {
                self.handleError(error: error, msg: "Unable to upload image")
                return
            }

            // Once the image is uploaded, retrieve its download URL
            imageRef.downloadURL { url, error in
                if let error = error {
                    self.handleError(error: error, msg: "Unable to retrieve image URL")
                    return
                }
                guard let url = url else { return }

                // Now upload the product data to Firestore with the image URL
                self.uploadDocument(url: url.absoluteString)
            }
        }
    }

    func uploadDocument(url: String) {
        var docRef: DocumentReference!
        var product = Product(name: name,
                              id: "",
                              category: selectedCategory.id,
                              price: price,
                              productDescription: productDescription,
                              imageUrl: url)

        // Check if we're editing an existing product or creating a new one
        if let productToEdit = productToEdit {
            docRef = Firestore.firestore().collection("products").document(productToEdit.id)
            product.id = productToEdit.id
        } else {
            docRef = Firestore.firestore().collection("products").document()
            product.id = docRef.documentID
        }

        let data = Product.modelToData(product: product)
        docRef.setData(data, merge: true) { error in

            if let error = error {
                self.handleError(error: error, msg: "Unable to upload Firestore document")
                return
            }

            self.navigationController?.popViewController(animated: true)

        }
    }

    func handleError(error: Error, msg: String) {
        debugPrint(error.localizedDescription)
        self.simpleAlert(title: "Error", msg: msg)
        self.activityIndicator.stopAnimating()
    }
}

// MARK: - Image Picker Methods
extension AddEditProductVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func launchImagePicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else { return }
        productImage.contentMode = .scaleAspectFill
        productImage.image = image
        dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
}
