//
//  CheckoutVC.swift
//  Artable
//
//  Created by Anup Saud on 2024-10-21.
//

import UIKit
import Stripe
import PassKit
import FirebaseFunctions

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
        paymentContext.requestPayment()
        activityIndicatorLabel.startAnimating()
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
        
        let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            self.navigationController?.popViewController(animated: true)
        }
        let retry = UIAlertAction(title: "Retry", style: .default) { (action) in
            self.paymentContext.retryLoading()
        }
        alertController.addAction(cancel)
        alertController.addAction(retry)
        present(alertController, animated: true, completion: nil)
        
        
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didCreatePaymentResult paymentResult: STPPaymentResult, completion: @escaping STPPaymentStatusBlock) {
          let idempotency = UUID().uuidString.replacingOccurrences(of: "-", with: "")
          
          let data : [String: Any] = [
              "total_amount" : StripeCart.total,
              "customer_id" : userService.user.stripeId,
              "payment_method_id" : paymentResult.paymentMethod?.stripeId ?? "",
              "idempotency" : idempotency
          ]
                  
          Functions.functions().httpsCallable("createCharge").call(data) { (result, error) in
              
              if let error = error {
                  debugPrint(error.localizedDescription)
                  self.simpleAlert(title: "Error", msg: "Unable to make charge.")
                  completion(STPPaymentStatus.error, error)
                  return
              }
              
              StripeCart.clearCart()
              self.tableView.reloadData()
              self.SetupPaymentInfo()
              completion(.success, nil)
          }
      }
    func paymentContext(_ paymentContext: Stripe.STPPaymentContext, didFinishWith status: StripePayments.STPPaymentStatus, error: (any Error)?) {
        let title: String
        let message: String
        
        switch status{
            
        case .success:
            activityIndicatorLabel.stopAnimating()
            title = "Sucess!"
            message = "Thank you for you purchase."
        case .error:
            activityIndicatorLabel.stopAnimating()
            title = "Error"
            message = error?.localizedDescription ?? ""
        case .userCancellation:
            return
        }
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default) { action in
            self.navigationController?.popViewController(animated: true)
        }
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
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
