//
//  ItemDetailViewController.swift
//  AuctionApp
//
//

import UIKit
import Foundation

class ItemDetailViewController: UIViewController {
  
  let ref = FIRDatabase.database().reference()
  var increments: [Int] = []
  
  @IBOutlet var itemDescriptionLabel: UILabel!
  @IBOutlet var itemTitleLabel: UILabel!
  @IBOutlet var itemImageView: UIImageView!
  @IBOutlet var currentBidLabel: UILabel!
  @IBOutlet var numberOfBidsLabel: UILabel!
  @IBOutlet var itemDonorLabel: UILabel!
  @IBOutlet var bidderSegmentedControl: UISegmentedControl!
  @IBOutlet var numAvailableLabel: UILabel!
  @IBOutlet var numOfBidsLabel: UILabel!
  @IBOutlet var biddingStatusLabel: UILabel!
  
  var detailItem: Item? {
    didSet {
      configureView()
    }
  }
  
  func configureView() {
    if let item = self.detailItem {
      if let itemDescriptionLabel = itemDescriptionLabel, let itemTitleLabel = itemTitleLabel, let itemImageView = itemImageView, let itemDonorLabel = itemDonorLabel, let currentBidLabel = currentBidLabel, let bidderSegmentedControl = bidderSegmentedControl, let numAvailableLabel = numAvailableLabel, let biddingStatusLabel = biddingStatusLabel, let numberOfBidsLabel = numberOfBidsLabel {
        print("ITEM", itemDescriptionLabel, itemTitleLabel, itemDonorLabel, numAvailableLabel)
        itemDescriptionLabel.text = item.description
        itemTitleLabel.text = item.name
        itemTitleLabel.sizeToFit()
        itemDonorLabel.text = item.addedByUser
        numAvailableLabel.text = String(item.quantity) + " Available"
        
        if item.imageUrl.characters.count > 0 {
          if let url = URL(string: item.imageUrl) {
            URLSession.shared.dataTask(with: url) { (data, response, error) in
              if (error != nil) {
                // print("Failed fetching image:", error)
              } else if let response = response as? HTTPURLResponse, response.statusCode != 200 {
                // print("Not a proper HTTPURLResponse or statusCode")
              } else if (data != nil) {
                // print("SUCCESS")
                DispatchQueue.main.async {
                  itemImageView.image = UIImage(data: data!)
                }
              }
            }.resume()
          }
        }
        
        if (item.numBids > 0) {
          numberOfBidsLabel.text = "WINNING BIDS (" + String(item.numBids) + " total bids)"
          currentBidLabel.text = item.getWinningBidsString()
        } else {
          numberOfBidsLabel.text = "SUGGESTED OPENING BID"
          currentBidLabel.text = "$" + String(item.openBid)
          currentBidLabel.textColor = UIColor(red:0.26, green:0.36, blue:0.46, alpha:1.0)
        }
        
        //bidderSegmentControl
        increments = item.getIncrements()
        
        let attr = [NSFontAttributeName: UIFont(name: "AvenirNext-Regular", size: 18) ?? UIFont.systemFont(ofSize: 18)]
        bidderSegmentedControl.setTitleTextAttributes(attr, for: UIControlState.normal)
        bidderSegmentedControl.setTitle("$" + String(increments[0]), forSegmentAt: 0)
        bidderSegmentedControl.setTitle("$" + String(increments[1]), forSegmentAt: 1)
        bidderSegmentedControl.setTitle("$" + String(increments[2]), forSegmentAt: 2)
        bidderSegmentedControl.selectedSegmentIndex = -1
        
        //biddingStatusLabel
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        
        // SMOKE TEST DATA
        //let BIDDING_OPENS = formatter.date(from: "2016/12/07 12:00")
        let BIDDING_OPENS = formatter.date(from: "2016/12/06 12:00")
        let BIDDING_CLOSES = formatter.date(from: "2016/12/07 18:00")
        let LIVE_BIDDING_OPENS = formatter.date(from: "2016/12/07 15:00")
        
        // LIVE AUCTION DATA
        // let BIDDING_OPENS = formatter.date(from: "2016/12/12 15:00")
        // let BIDDING_CLOSES = formatter.date(from: "2016/12/14 20:00")
        // let LIVE_BIDDING_OPENS = formatter.date(from: "2016/12/14 17:00")
        
        let now = NSDate()
        formatter.dateFormat = "MM/dd HH:mm"
        
        if (now.compare(BIDDING_CLOSES!) == ComparisonResult.orderedDescending) {
          bidderSegmentedControl.isEnabled = false
          bidderSegmentedControl.tintColor = UIColor(red:0.26, green:0.36, blue:0.46, alpha:1.0)
          biddingStatusLabel.text = ("Sorry, bidding has closed").uppercased()
        }
        if (item.isLive) {
          if (now.compare(LIVE_BIDDING_OPENS!) == ComparisonResult.orderedDescending) {
            biddingStatusLabel.text = ("Bidding closes " + formatter.string(from: BIDDING_CLOSES!)).uppercased()
          } else {
            bidderSegmentedControl.isEnabled = false
            bidderSegmentedControl.tintColor = UIColor(red:0.26, green:0.36, blue:0.46, alpha:1.0)
            biddingStatusLabel.text = ("Bidding opens " + formatter.string(from: LIVE_BIDDING_OPENS!)).uppercased()
          }
        } else {
          if (now.compare(BIDDING_OPENS!) == ComparisonResult.orderedDescending) {
            biddingStatusLabel.text = ("Bidding closes " + formatter.string(from: BIDDING_CLOSES!)).uppercased()
          } else {
            bidderSegmentedControl.isEnabled = false
            bidderSegmentedControl.tintColor = UIColor(red:0.26, green:0.36, blue:0.46, alpha:1.0)
            biddingStatusLabel.text = ("Bidding opens " + formatter.string(from: BIDDING_OPENS!)).uppercased()
          }
        }
      }
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configureView()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  @IBAction func indexChanged(sender:UISegmentedControl) {
    switch bidderSegmentedControl.selectedSegmentIndex {
      case 0:
        alertBid()
      case 1:
        alertBid()
      case 2:
        alertBid()
      case 3:
        alertCustomBid()
      default:
        break;
    }
  }
  
  func alertCustomBid() {
    let alert = UIAlertController(title: "Custom bid", message: "Enter custom bid amount", preferredStyle: .alert)
    
    alert.addTextField { textField in
      textField.keyboardType = UIKeyboardType.numberPad
      textField.placeholder = "Minimum bid: $" + String(self.detailItem!.getPrice())
    }
  
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
      self.bidderSegmentedControl.selectedSegmentIndex = -1
    }
    
    let saveAction = UIAlertAction(title: "OK", style: .default) { (action) in
      let input = alert.textFields![0].text ?? "0"
      self.increments.append(Int(input)!)
      self.alertBid()
    }
    
    alert.addAction(saveAction)
    alert.addAction(cancelAction)
    
    self.present(alert, animated: true)
  }
  
  func alertBid() {
    if let item = self.detailItem {
      let alertController = UIAlertController(title: "Submit bid?", message: "Bid $" + String(increments[bidderSegmentedControl.selectedSegmentIndex]) + " on " + item.name, preferredStyle: .alert)
      
      let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
        self.bidderSegmentedControl.selectedSegmentIndex = -1
      }
      
      let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in
        print("OK")
        self.bidOn(item: item, amount: self.increments[self.bidderSegmentedControl.selectedSegmentIndex])
        self.bidderSegmentedControl.selectedSegmentIndex = -1
      }
      
      alertController.addAction(cancelAction)
      alertController.addAction(OKAction)
      
      self.present(alertController, animated: true)
    }
  }
  
  func bidOn(item:Item, amount: Int){
    let user = FIRAuth.auth()?.currentUser;
    
    if let userEmail = user?.email {
      let postRef = self.ref.child("bids").childByAutoId()
      let bidId = postRef.key
      postRef.setValue(["user": user!.uid, "amount": amount, "item": item.id] as [String : Any])
      self.ref.child("/item-bids/" + item.id + "/" + bidId).setValue(["user": user!.uid, "amount": amount] as [String : Any])
      self.ref.child("/items/" + item.id + "/bids/" + bidId).setValue(true)
      self.ref.child("/users/" + user!.uid + "/item-bids/" + item.id).child(bidId).setValue(true)
      
      /*item.ref?.updateChildValues([
        "bids": item.bids.add(["email": userEmail, "name": "A HubSpotter", "amount": 50]).copy()
      ])*/
    }
  }
}

