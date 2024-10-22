//
//  CheckoutVC.swift
//  Artable
//
//  Created by Anup Saud on 2024-10-21.
//

import UIKit

class CheckoutVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var paymentMethodButton: UIButton!
    @IBOutlet weak var shippingMethodButton: UIButton!
    @IBOutlet weak var subtotalLabel: UILabel!
    @IBOutlet weak var processingFeeLabel: UILabel!
    @IBOutlet weak var shippingHandlingCostLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var activityIndicatorLabel: UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

  
    @IBAction func placeOrderButtonPressed(_ sender: Any) {
    }
    
    @IBAction func paymentMethodPressed(_ sender: Any) {
    }
    
    @IBAction func shippingMethodPressed(_ sender: Any) {
    }
    
}
