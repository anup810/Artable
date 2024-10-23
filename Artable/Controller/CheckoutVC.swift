//
//  CheckoutVC.swift
//  Artable
//
//  Created by Anup Saud on 2024-10-21.
//

import UIKit
import Stripe
import PassKit

class CheckoutVC: UIViewController, CartItemDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var paymentMethodButton: UIButton!
    @IBOutlet weak var shippingMethodButton: UIButton!
    @IBOutlet weak var subtotalLabel: UILabel!
    @IBOutlet weak var processingFeeLabel: UILabel!
    @IBOutlet weak var shippingHandlingCostLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var activityIndicatorLabel: UIActivityIndicatorView!
    
    var paymentContext: STPPaymentContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SetupTableView()
        SetupPaymentInfo()
        setupStripeConfig()
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
    
    
    func setupStripeConfig() {
        let config = STPPaymentConfiguration.shared
        config.requiredBillingAddressFields = .none
        config.requiredShippingAddressFields = [.postalAddress]
        
        let customerContext = STPCustomerContext(keyProvider: StripeApi)
        paymentContext = STPPaymentContext(customerContext: customerContext, configuration: config, theme: .defaultTheme)
        
        paymentContext.paymentAmount = StripeCart.total
        paymentContext.delegate = self
        paymentContext.hostViewController = self
    }

    

  
    @IBAction func placeOrderButtonPressed(_ sender: Any) {
    }
    
    @IBAction func paymentMethodPressed(_ sender: Any) {
        paymentContext.pushPaymentOptionsViewController()
    }
    
    @IBAction func shippingMethodPressed(_ sender: Any) {
        paymentContext.pushShippingViewController()
    }
    
    func removeItem(product: Product) {
        StripeCart.removeItemFromCart(item: product)
        tableView.reloadData()
        SetupPaymentInfo()
        paymentContext.paymentAmount = StripeCart.total

    }
    
    
}
extension CheckoutVC : STPPaymentContextDelegate{
    func paymentContext(_ paymentContext: Stripe.STPPaymentContext, didFailToLoadWithError error: any Error) {
        
    }
    
    func paymentContext(_ paymentContext: Stripe.STPPaymentContext, didCreatePaymentResult paymentResult: Stripe.STPPaymentResult, completion: @escaping StripePayments.STPPaymentStatusBlock) {
        
    }
    
    func paymentContext(_ paymentContext: Stripe.STPPaymentContext, didFinishWith status: StripePayments.STPPaymentStatus, error: (any Error)?) {
        
        
    }
    
    func paymentContextDidChange(_ paymentContext: Stripe.STPPaymentContext) {
        //updating selected payment Method
        if let paymentMethod = paymentContext.selectedPaymentOption {
            paymentMethodButton.setTitle(paymentMethod.label, for: .normal)
            
        }else{
            paymentMethodButton.setTitle("Select Method", for: .normal)
        }
        
        // updating the selected shipping method
        if let shippingMethod = paymentContext.selectedShippingMethod{
            shippingMethodButton.setTitle(shippingMethod.label, for: .normal)
            StripeCart.shippingFees = Int(Double(truncating: shippingMethod.amount) * 100)
            SetupPaymentInfo()
        }else{
            shippingMethodButton.setTitle("Select Method", for: .normal)
        }
        
    }
    func paymentContext(_ paymentContext: STPPaymentContext, didUpdateShippingAddress address: STPAddress, completion: @escaping STPShippingMethodsCompletionBlock) {
        let upsGround = PKShippingMethod()
        upsGround.amount = 0
        upsGround.label = "UPS Ground"
        upsGround.detail = "Arrives in 2-4 days"
        upsGround.identifier = "ups_ground"
        
        let fedEx = PKShippingMethod()
        fedEx.amount = 6.99
        fedEx.label = "FedEx"
        fedEx.detail = "Arrives tomorrow"
        fedEx.identifier = "fedex"
        
        // Validate against correct country codes
        if address.country == "CA" || address.country == "US" {
            // If the country is Canada or US, accept the address
            completion(.valid, nil, [upsGround, fedEx], fedEx)
        } else {
            // For other countries, mark the address as invalid
            completion(.invalid, nil, nil, nil)
        }
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
