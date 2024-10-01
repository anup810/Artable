//
//  AddEditCategoryVC.swift
//  ArtableAdmin
//
//  Created by Anup Saud on 2024-09-27.
//

import UIKit
import FirebaseStorage
import FirebaseFirestore
import Kingfisher

class AddEditCategoryVC: UIViewController {
    
    // Outlet for the activity indicator to show loading state
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // Outlet for the category image view, which will allow users to tap and select an image
    @IBOutlet weak var categoryImage: RoundedImageView!
    
    // Outlet for the category name text field
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var addButton: UIButton!
    var categoryToEdit: Category?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup tap gesture recognizer on the category image to launch the image picker
        let tap = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
        tap.numberOfTapsRequired = 1
        categoryImage.isUserInteractionEnabled = true
        categoryImage.addGestureRecognizer(tap)
        
        // if we are editing, categoryToEdit will != nil
        if let category = categoryToEdit{
            nameText.text = category.name
            addButton.setTitle("Save Changes", for: .normal)
            
            if let url = URL(string: category.imageUrl){
                categoryImage.contentMode = .scaleAspectFill
                categoryImage.kf.setImage(with: url)
            }
        }
    }
    
    // Function to handle image tap and trigger image picker
    @objc func imageTapped(_ tap: UITapGestureRecognizer) {
        // Launch the image picker when the image is tapped
        lanuchImagePicker()
    }
    
    // Action for the 'Add Category' button
    // This function is triggered when the user clicks the button to add a category.
    // It starts the activity indicator and begins the process of uploading the image
    // and the category information to Firebase Storage and Firestore.
    @IBAction func addCategoryClicked(_ sender: Any) {
        activityIndicator.startAnimating()  // Start activity indicator to show loading
        uploadImageThenDocument()  // Initiates the image and document upload process
    }
    
    // Function to upload an image to Firebase Storage and then upload the document to Firestore
    // This method first uploads the category image, retrieves the download URL,
    // and finally uploads a category document containing the image URL and category details to Firestore.
    func uploadImageThenDocument(){
        // Ensure both the image and category name are available before continuing
        guard let image = categoryImage.image, let categoryName = nameText.text, categoryName.isNotEmpty else {
            simpleAlert(title: "Error", msg: "Must add category image and name")
            return
        }
        
        // Compress the image to reduce size before uploading
        guard let imageData = image.jpegData(compressionQuality: 0.2) else { return }
        
        // Create a reference in Firebase Storage where the image will be uploaded
        let imageRef = Storage.storage().reference().child("/CategoryImages/\(categoryName).jpg")
        
        // Set the metadata for the image to indicate that it is a JPEG image
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        
        // Upload the image data to Firebase Storage
        imageRef.putData(imageData, metadata: metaData) { metadata, error in
            if let error = error {
                // Handle any errors that occur during the upload process
                self.handleError(error: error, msg: "Unable to upload image")
            }
            
            // Once the image is uploaded, retrieve its download URL
            imageRef.downloadURL { url, error in
                if let error = error {
                    // Handle any errors that occur while retrieving the URL
                    self.handleError(error: error, msg: "Unable to retrieve image URL")
                }
                guard let url = url else { return }
                
                // Upload the category document to Firestore with the image URL
                self.uploadDocument(url: url.absoluteString)
            }
        }
    }
    
    // Function to upload the category document to Firestore
    // This function is called after the image is successfully uploaded to Firebase Storage.
    func uploadDocument(url: String){
        
        // Create a document reference for the "categories" collection in Firestore.
        var docRef: DocumentReference!
        
        // Create a new Category object using the provided category name, an empty id,
        // the image URL from Firebase Storage, and a timestamp for when the category was created.
        var category = Category.init(name: nameText.text!,
                                     id: "",
                                     imageUrl: url,
                                     timeStamp: Timestamp())
        
        // Create a new document reference in the "categories" collection.
        if let categoryToEdit = categoryToEdit{
            docRef = Firestore.firestore().collection("categories").document(categoryToEdit.id)
            category.id = categoryToEdit.id
            
        }else{
            //New Category
            docRef = Firestore.firestore().collection("categories").document()
            
            // Assign the document ID generated by Firestore to the category's id property.
            category.id = docRef.documentID
        }

        
        // Convert the category object to a dictionary format that Firestore can accept.
        let data = Category.modelToData(category: category)
        
        // Set the data in Firestore, merging it if necessary.
        docRef.setData(data, merge: true) { error in
            if let error = error {
                // Handle any errors during the upload process
                self.handleError(error: error, msg: "Unable to upload document")
            }
            
            // If the upload is successful, navigate back to the previous screen.
            self.navigationController?.popViewController(animated: true)
        }
    }

    // Function to handle errors during image upload or Firestore operations
    // This function centralizes error handling to avoid code duplication.
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

// Extension to handle image picking from the user's photo library
extension AddEditCategoryVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // Function to initialize and present the image picker controller
    func lanuchImagePicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }

    // Delegate method to handle image selection
    // When the user selects an image, this method is called to set the selected image
    // to the categoryImage view and dismiss the image picker.
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else { return }
        categoryImage.contentMode = .scaleAspectFill
        categoryImage.image = image
        dismiss(animated: true, completion: nil)
    }

    // Delegate method to handle image picker cancellation
    // If the user cancels the image selection, the image picker is dismissed.
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
