//
//  CheckoutVC.swift
//  Artable
//
//  Created by Anup Saud on 2024-10-21.
//

import UIKit

class CheckoutVC: UIViewController, CartItemDelegate {

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
        SetupTableView()
        SetupPaymentInfo()
    }
    
    func SetupTableView(){
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: Identifier.CartItemCell, bundle: nil), forCellReuseIdentifier: Identifier.CartItemCell)
        
    }
    func SetupPaymentInfo(){
        subtotalLabel.text = StripeCart.subtotal.penniesToFormattedCurrency()
        processingFeeLabel.text = StripeCart.processingFees.penniesToFormattedCurrency()
        shippingHandlingCostLabel.text = StripeCart.shippingFees.penniesToFormattedCurrency()
        totalLabel.text = StripeCart.total.penniesToFormattedCurrency()
    }
    

  
    @IBAction func placeOrderButtonPressed(_ sender: Any) {
    }
    
    @IBAction func paymentMethodPressed(_ sender: Any) {
    }
    
    @IBAction func shippingMethodPressed(_ sender: Any) {
    }
    
    func removeItem(product: Product) {
        StripeCart.removeItemFromCart(item: product)
        tableView.reloadData()
        SetupPaymentInfo()

    }
    
    
}
extension CheckoutVC : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StripeCart.cartItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: Identifier.CartItemCell, for: indexPath) as? CartItemCell{
            let product = StripeCart.cartItems[indexPath.row]
            cell.configureCell(product: product, delegate: self)
            return cell
        }
        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    
}
