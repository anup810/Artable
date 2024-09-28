//
//  AddEditCategoryVC.swift
//  ArtableAdmin
//
//  Created by Anup Saud on 2024-09-27.
//

import UIKit

class AddEditCategoryVC: UIViewController {

    // Outlet for the activity indicator to show loading state
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // Outlet for the category image view, which will allow users to tap and select an image
    @IBOutlet weak var categoryImage: RoundedImageView!
    
    // Outlet for the category name text field
    @IBOutlet weak var nameText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup tap gesture recognizer on the category image to launch the image picker
        let tap = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
        tap.numberOfTapsRequired = 1
        categoryImage.isUserInteractionEnabled = true
        categoryImage.addGestureRecognizer(tap)
    }
    
    // Function to handle image tap and trigger image picker
    @objc func imageTapped(_ tap: UITapGestureRecognizer) {
        // Launch the image picker when the image is tapped
        lanuchImagePicker()
    }

    // Action for the 'Add Category' button
    @IBAction func addCategoryClicked(_ sender: Any) {
        // Placeholder for adding category functionality
    }
    
}

extension AddEditCategoryVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // Function to initialize and present the image picker controller
    func lanuchImagePicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }

    // Delegate method to handle image selection
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Retrieve and set the selected image to the category image view
        guard let image = info[.originalImage] as? UIImage else { return }
        categoryImage.contentMode = .scaleAspectFill
        categoryImage.image = image
        dismiss(animated: true, completion: nil)
    }

    // Delegate method to handle image picker cancellation
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss the image picker when cancelled
        dismiss(animated: true, completion: nil)
    }
}
