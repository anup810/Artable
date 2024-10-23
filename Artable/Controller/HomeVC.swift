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
    let db = Firestore.firestore()
    var listener: ListenerRegistration!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        // If there's no current user, sign in anonymously
        setupInitialAnonymousUser()
        setupNavigationBar()
    }
    func setupNavigationBar(){
        navigationItem.title = "Artable"
        guard let font = UIFont(name: "futura", size: 26) else {return}
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: font
        ]
        
    }
    
    func setupCollectionView(){
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "CategoryCell", bundle: nil), forCellWithReuseIdentifier: "CategoryCell")
    }
    func setupInitialAnonymousUser(){
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
        setCategoriesListener()
        updateLoginOutButton() // Ensure button is up to date when the view appears
    }
    override func viewWillDisappear(_ animated: Bool) {
        listener.remove()
        categories.removeAll()
        collectionView.reloadData()
    }
    
    func setCategoriesListener(){
        listener = db.categories.addSnapshotListener({ snap, error in
            if let error = error{
                debugPrint(error.localizedDescription)
                return
            }
            
            snap?.documentChanges.forEach({ change in
                let data = change.document.data()
                let category = Category(data: data)
                
                switch change.type{
                case .added:
                    self.onDocumentAdded(change: change, category: category)
                case .modified:
                    self.onDocumentModified(change: change, category: category)
                case .removed:
                    self.onDocumentRemoved(change: change)
                }
            })
        })
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
                // If the user is anonymous, set the button title to "Login"
                loginOutButton.title = "Login"
            } else {
                // If the user is logged in (non-anonymous), set the button title to "Logout"
                loginOutButton.title = "Logout"
                
                // Check if userListener is nil, then fetch the current user
                if userService.userListener == nil {
                    userService.getCurrentUser()
                }
            }
        } else {
            // If there is no user logged in, set the button title to "Login"
            loginOutButton.title = "Login"
        }
    }

    @IBAction func favoriteButtonClicked(_ sender: Any) {
        if userService.isGuest{
            self.simpleAlert(title: "Message", msg: "This is a user only feature, please create a registered user to take advantage of all out features")
            return
        }
        performSegue(withIdentifier: Segus.ToFavorites, sender: self)
    }
    
    @IBAction func loginOutButtonClicked(_ sender: Any) {
        if let user = Auth.auth().currentUser {
            if user.isAnonymous {
                presentLoginController() // Present login if user is anonymous
            } else {
                do {
                    try Auth.auth().signOut() // Sign out if logged in
                    userService.logoutUser()
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
    
    func onDocumentAdded(change:DocumentChange, category: Category){
        let newIndex = Int(change.newIndex)
        categories.insert(category, at: newIndex)
        collectionView.insertItems(at: [IndexPath(item: newIndex, section: 0)])
        
    }
    func onDocumentModified(change:DocumentChange, category: Category){
        //Item changed but remain at the same Index
        if change.newIndex == change.oldIndex{
            let index = Int(change.newIndex)
            categories[index] = category
            collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
            
            
        }else{
            //Item changed and change position
            let newIndex = Int(change.newIndex)
            let oldIndex = Int(change.oldIndex)
            
            categories.remove(at: oldIndex)
            categories.insert(category, at: newIndex)
            
            collectionView.moveItem(at: IndexPath(item: oldIndex, section: 0), to: IndexPath(item: newIndex, section: 0))
        }
        
    }
    
    func onDocumentRemoved(change: DocumentChange){
        let oldIndex = Int(change.oldIndex)
        categories.remove(at: oldIndex)
        collectionView.deleteItems(at: [IndexPath(item: oldIndex, section: 0)])
        
    }
    
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
        }else if segue.identifier == Segus.ToFavorites{
            if let destination = segue.destination as? ProductVC{
                destination.category = selectedCategory
                destination.showFavorites = true
            }
        }
    }
    
}

// code for reference
// func to fetch data from firestore
//    func fetchDocument(){
//        let docRef = db.collection("categories").document("b5HovHXAtBr67lSWvY38")
//        listener = docRef.addSnapshotListener { snap, error in
//            self.categories.removeAll()
//            guard let data = snap?.data() else {return}
//            let newCategory = Category.init(data: data)
//            self.categories.append(newCategory)
//            self.collectionView.reloadData()
//        }
//
    
    //        docRef.getDocument { snap, error in
    //            guard let data = snap?.data() else {return}
    //            let newCategory = Category.init(data: data)
    //            self.categories.append(newCategory)
    //            self.collectionView.reloadData()
    //
    //        }
// }
//    func fetchCollection(){
//        let collectionReference = db.collection("categories")
//        listener = collectionReference.addSnapshotListener { snap, error in
//            guard let documents = snap?.documents else {return}
//            print(snap?.documentChanges.count)
//            self.categories.removeAll()
//            for document in documents{
//                let data = document.data()
//                let newCategory = Category.init(data: data)
//                self.categories.append(newCategory)
//            }
//            self.collectionView.reloadData()
//        }
    
//
//        collectionReference.getDocuments { snap, error in
//            guard let documents = snap?.documents else {return}
//            for document in documents{
//                let data = document.data()
//                let newCategory = Category.init(data: data)
//                self.categories.append(newCategory)
//            }
//            self.collectionView.reloadData()
//        }
//    }
