//
//  ProductVC.swift
//  Artable
//
//  Created by Anup Saud on 2024-09-22.
//

import UIKit
import FirebaseFirestore

class ProductVC: UIViewController {
    //outlets
    @IBOutlet weak var tableView: UITableView!
    
    //variables
    var products = [Product]()
    var category : Category!
    let db = Firestore.firestore()
    var listener: ListenerRegistration!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: Identifier.ProductCell, bundle: nil), forCellReuseIdentifier: Identifier.ProductCell)


        // Do any additional setup after loading the view.
        setProductsListener()
    }
    
    func setProductsListener(){
        listener = db.products.whereField("category", isEqualTo: category.id).order(by: "timeStamp",descending: true).addSnapshotListener({ snap, error in
            if let error = error{
                debugPrint(error.localizedDescription)
                return
            }
            
            snap?.documentChanges.forEach({ change in
                let data = change.document.data()
                let product = Product.init(data: data)
                
                switch change.type{
                    
                case .added:
                    self.onDocumentAdd(change: change, product: product)
                case .modified:
                    self.onDocumentModified(change: change, product: product)
                case .removed:
                    self.onDocumentRemove(change: change)
                }
            })
        })
    }
}



extension ProductVC : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: Identifier.ProductCell, for: indexPath) as? ProductCell {
            cell.configureCell(product: products[indexPath.row])
            return cell
            
        }
        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    func onDocumentAdd(change: DocumentChange, product: Product){
        let newIndex = Int(change.newIndex)
        products.insert(product, at: newIndex)
        tableView.insertRows(at: [IndexPath(row: newIndex, section: 0)], with: .automatic)
    

        
    }
    func onDocumentModified(change: DocumentChange, product: Product){
        if change.newIndex == change.oldIndex{
            //Item changed but remain at the same Index
            let index = Int(change.newIndex)
            products[index] = product
            tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
        }else {
            //Item changed and change position
            let newIndex = Int(change.newIndex)
            let oldIndex = Int(change.oldIndex)
            
            products.remove(at: oldIndex)
            products.insert(product, at: newIndex)
            
            tableView.moveRow(at: IndexPath(row: oldIndex, section: 0), to: IndexPath(item: newIndex, section: 0))
        }
        
    }
    func onDocumentRemove(change: DocumentChange){
        let oldIndex = Int(change.oldIndex)
        products.remove(at: oldIndex)
        tableView.deleteRows(at: [IndexPath(row: oldIndex, section: 0)], with: .left)
        
    }
    
    
}
