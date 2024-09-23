//
//  ViewController.swift
//  Artable
//
//  Created by Anup Saud on 2024-09-16.
//

import UIKit
import Firebase

class HomeVC: UIViewController {
    @IBOutlet weak var loginOutButton: UIBarButtonItem!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    // variables
    var categories = [Category]()
    var selectedCategory: Category!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let category = Category.init(name: "Nature", id: "NOTHING", imageUrl: "https://images.unsplash.com/photo-1726510114046-b7938cdc1bd1?q=80&w=1974&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",isActive: true, timeStamp: Timestamp())
        categories.append(category)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "CategoryCell", bundle: nil), forCellWithReuseIdentifier: "CategoryCell")
        // If there's no current user, sign in anonymously
        if Auth.auth().currentUser == nil {
            Auth.auth().signInAnonymously { result, error in
                if let error = error {
                    debugPrint("Error signing in anonymously: \(error.localizedDescription)")
                    Auth.auth().handleFireAuthError(error: error,vc: self)
                } else if let user = result?.user {
                    print("Anonymous user signed in: \(user.uid)")
                    self.updateLoginOutButton()
                }
            }
        } else {
            updateLoginOutButton() // Update button if user is already signed in
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateLoginOutButton() // Ensure button is up to date when the view appears
    }
    
    fileprivate func presentLoginController() {
        let storyboard = UIStoryboard(name: "LoginStoryboard", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "LoginVC")
        controller.modalPresentationStyle = .fullScreen
        present(controller, animated: true, completion: nil)
    }

    fileprivate func updateLoginOutButton() {
        if let user = Auth.auth().currentUser {
            if user.isAnonymous {
                loginOutButton.title = "Login"
            } else {
                loginOutButton.title = "Logout"
            }
        }
    }

    @IBAction func loginOutButtonClicked(_ sender: Any) {
        if let user = Auth.auth().currentUser {
            if user.isAnonymous {
                presentLoginController() // Present login if user is anonymous
            } else {
                do {
                    try Auth.auth().signOut() // Sign out if logged in
                    presentLoginController() // Show login after sign out
                } catch {
                    debugPrint("Error signing out: \(error.localizedDescription)")
                    Auth.auth().handleFireAuthError(error: error,vc: self)
                }
            }
        } else {
            presentLoginController() // Present login if no user exists
        }
    }
}

extension HomeVC : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Identifier.CategoryCell, for: indexPath) as? CategoryCell{
            cell.configureCell(category: categories[indexPath.item])
            return cell
            
        }
        return UICollectionViewCell()
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width
        let cellWidth = (width - 30) / 2
        let cellHeight = cellWidth * 1.5
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedCategory = categories[indexPath.item]
        performSegue(withIdentifier: Segus.ToProducts, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segus.ToProducts{
            if let destination = segue.destination as? ProductVC{
                destination.category = selectedCategory
            }
        }
    }
    
}
