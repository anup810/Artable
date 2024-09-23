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
    var prodcuts = [Product]()
    var category : Category!

    override func viewDidLoad() {
        super.viewDidLoad()
        let product = Product.init(name: "LandScape", id: "Nothing", category: "Nature", price: 24.99, productDescription: "Test Image", imageURL: "https://plus.unsplash.com/premium_photo-1669750822199-fc9114724dd4?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D", timeStamp: Timestamp(), stock: 0, favorite: false)
            prodcuts.append(product)
        
        
     
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: Identifier.ProductCell, bundle: nil), forCellReuseIdentifier: Identifier.ProductCell)


        // Do any additional setup after loading the view.
    }
    

}

extension ProductVC : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return prodcuts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: Identifier.ProductCell, for: indexPath) as? ProductCell {
            cell.configureCell(product: prodcuts[indexPath.row])
            return cell
            
        }
        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    
}
