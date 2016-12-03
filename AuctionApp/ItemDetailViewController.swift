//
//  ItemDetailViewController.swift
//  AuctionApp
//
//

import UIKit
import Foundation

class ItemDetailViewController: UIViewController {
  
  let ref = FIRDatabase.database().reference()
  
  @IBOutlet var itemDescriptionLabel: UILabel!
  @IBOutlet var itemTitleLabel: UILabel!
  @IBOutlet var itemImageView: UIImageView!
  @IBOutlet var currentBidLabel: UILabel!
  //@IBOutlet var numberOfBidsLabel: UILabel!
  @IBOutlet var itemDonorLabel: UILabel!
  @IBOutlet var bidderSegmentedControl: UISegmentedControl!
  //@IBOutlet var headerBackground: UIView!
  @IBOutlet var numAvailableLabel: UILabel!
  @IBOutlet var biddingStatusLabel: UILabel!
  
  var detailItem: Item? {
    didSet {
      configureView()
    }
  }
  
  func configureView() {
    if let item = self.detailItem {
      if let itemDescriptionLabel = itemDescriptionLabel, let itemTitleLabel = itemTitleLabel, let itemImageView = itemImageView, let itemDonorLabel = itemDonorLabel, let currentBidLabel = currentBidLabel, let bidderSegmentedControl = bidderSegmentedControl {
        itemDescriptionLabel.text = item.description
        itemTitleLabel.text = item.name
        itemDonorLabel.text = item.addedByUser
        numAvailableLabel.text = item.quantity.stringValue + " Available"
        
        if item.imageUrl.characters.count > 0 {
          print("IMAGEURL", item.imageUrl)
          if let url = URL(string: item.imageUrl) {
            URLSession.shared.dataTask(with: url) { (data, response, error) in
              if (error != nil) {
                print("Failed fetching image:", error)
              } else if let response = response as? HTTPURLResponse, response.statusCode != 200 {
                print("Not a proper HTTPURLResponse or statusCode")
              } else if (data != nil) {
                print("SUCCESS")
                DispatchQueue.main.async {
                  itemImageView.image = UIImage(data: data!)
                }
              }
            }.resume()
          }
        }
        
        // var itemsRef = self.ref.child("items");
        // var itemBidsRef = itemsRef.child(item.id).child("bids");
        // itemBidsRef.on("child_added", function(snap) {
        // itemsRef.child(snap.key()).once("value", function() {
        //   // Render the bid on the item page.
        //  });
        // });
        
        print(item.bids)
        
        currentBidLabel.text = "$" + item.openBid.stringValue
        
        let attr = [NSFontAttributeName: UIFont(name: "Avenir Next", size: 24) ?? UIFont.systemFont(ofSize: 17)]
        bidderSegmentedControl.setTitleTextAttributes(attr, for: UIControlState.normal)
        bidderSegmentedControl.setTitle("+$10", forSegmentAt: 0)
        bidderSegmentedControl.setTitle("+$25", forSegmentAt: 1)
        bidderSegmentedControl.setTitle("+$50", forSegmentAt: 2)
        bidderSegmentedControl.selectedSegmentIndex = -1
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        // let BIDDING_OPENS = formatter.date(from: "2016/12/12 15:00")
        let BIDDING_OPENS = formatter.date(from: "2016/11/11 15:00")
        let BIDDING_CLOSES = formatter.date(from: "2016/12/14 20:00")
        let LIVE_BIDDING_OPENS = formatter.date(from: "2016/12/14 17:00")
        
        let now = NSDate()
        
        if (now.compare(BIDDING_CLOSES!) == ComparisonResult.orderedDescending) {
          // cell.bidNowButton.isHidden = true
          biddingStatusLabel.text = ("Sorry, bidding has closed").uppercased()
        }
        if (item.isLive) {
          if (now.compare(LIVE_BIDDING_OPENS!) == ComparisonResult.orderedDescending) {
            biddingStatusLabel.text = ("Bidding closes " + formatter.string(from: BIDDING_CLOSES!)).uppercased()
          } else {
            // cell.bidNowButton.isHidden = true
            biddingStatusLabel.text = ("Bidding opens " + formatter.string(from: LIVE_BIDDING_OPENS!)).uppercased()
          }
        } else {
          if (now.compare(BIDDING_OPENS!) == ComparisonResult.orderedDescending) {
            biddingStatusLabel.text = ("Bidding closes " + formatter.string(from: BIDDING_CLOSES!)).uppercased()
          } else {
            // cell.bidNowButton.isHidden = true
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
      default:
        break;
    }
  }
  
  func alertBid() {
    if let item = self.detailItem {
      let alertController = UIAlertController(title: "Submit bid?", message: "Bid $" + item.openBid.stringValue + " on " + item.name, preferredStyle: .alert)
      
      let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
        // ...
      }
      alertController.addAction(cancelAction)
      
      let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in
        self.bidOn(item: item, amount: 50)
      }
      alertController.addAction(OKAction)
      
      self.present(alertController, animated: true) {
        // ...
      }
    }
  }
  
  //func bidOn(item:Item, amount: Int, completion: (Bool, errorCode: String) -> ()){
  
  func bidOn(item:Item, amount: Int){
    let user = FIRAuth.auth()?.currentUser;
    
    if let userEmail = user?.email {
      let bidData = ["email": userEmail, "name": "A HubSpotter", "amount": 50, "item": 0] as [String : Any]
      let postRef = self.ref.child("bids").childByAutoId()
      var bidId = postRef.key
      postRef.setValue(bidData)
      self.ref.child("/items/" + item.id + "/bids/" + bidId).setValue(true)
      // self.ref.child("/users/" + comment.author + "/bids/" + name).set(true);

      /*print("BIDS", item.bids)
      print("ALL BIDS", item.bids.add(["email": userEmail, "name": "A HubSpotter", "amount": 50]))
      

      id.set(comment, function(err) {
        if (!err) {
          var name = id.key();
          root.child("/links/" + comment.link + "/comments/" + name).set(true);
          root.child("/users/" + comment.author + "/comments/" + name).set(true);
        }
      });*/
      
      
      /*item.ref?.updateChildValues([
        "bids": item.bids.add(["email": userEmail, "name": "A HubSpotter", "amount": 50]).copy()
      ])*/
    }
    
    /*Bid(email: user.email, name: user.username, amount: amount, itemId: item.objectId)
      .saveInBackgroundWithBlock { (success, error) -> Void in
        
        if error != nil {
          
          if let errorString:String = error.userInfo?["error"] as? String{
            completion(false, errorCode: errorString)
          }else{
            completion(false, errorCode: "")
          }
          return
        }
        
        let newItemQuery: PFQuery = Item.query()
        newItemQuery.whereKey("objectId", equalTo: item.objectId)
        newItemQuery.getFirstObjectInBackgroundWithBlock({ (item, error) -> Void in
          
          if let itemUW = item as? Item {
            self.replaceItem(itemUW)
          }
          completion(true, errorCode: "")
        })
        
        let channel = "a\(item.objectId)"
        PFPush.subscribeToChannelInBackground(channel, block: { (success, error) -> Void in
          
        })
    }*/
  }
}

