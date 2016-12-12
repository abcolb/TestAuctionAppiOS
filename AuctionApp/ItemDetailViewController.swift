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
  var item: Item?

  @IBOutlet var itemDescriptionLabel: UILabel!
  @IBOutlet var itemTitleLabel: UILabel!
  @IBOutlet var itemImageView: UIImageView!
  @IBOutlet var currentBidLabel: UILabel!
  @IBOutlet var numberOfBidsLabel: UILabel!
  @IBOutlet var itemDonorLabel: UILabel!
  @IBOutlet var bidderSegmentedControl: UISegmentedControl!
  @IBOutlet var numOfBidsLabel: UILabel!
  @IBOutlet var biddingStatusLabel: UILabel!

  var itemKey: String? {
    didSet {
      self.ref.child("items").child(self.itemKey!).observe(.value, with: { snapshot in
        var auctionItem = Item(snapshot: snapshot)
          if (auctionItem.numBids != 0) {
            var winningBids: [Bid] = []
            let winningBidsQuery = self.ref.child("item-bids").child(auctionItem.id).queryOrdered(byChild: "amount").queryLimited(toLast: UInt(auctionItem.quantity))
            winningBidsQuery.observeSingleEvent(of: .value, with: { (snapshot) in
              for child in snapshot.children {
                let bid = Bid(snapshot: child as! FIRDataSnapshot)
                winningBids.append(bid)
                print("ITEM", auctionItem)
                print("BID USER", bid.user)
                print("UUID", self.getUid())
                print("TRUE?", bid.user == self.getUid())
                if (bid.user == self.getUid()){
                  auctionItem.userIsWinning = true
                  auctionItem.userWinningBids.append(bid)
                }
              }
              auctionItem.winningBids = winningBids
              self.ref.child("users").child(self.getUid()).child("item-bids").child(auctionItem.id).observeSingleEvent(of: .value, with: { (snapshot) in
                if (snapshot.childrenCount > 0 && auctionItem.userIsWinning == false) {
                  auctionItem.userIsOutbid = true;
                }
                self.item = auctionItem
                self.configureView()
              })
            })
          } else {
            self.item = auctionItem
            self.configureView()
          }
        })
    }
  }

  func configureView() {
    if (self.item != nil) {
      if let itemDescriptionLabel = itemDescriptionLabel, let itemTitleLabel = itemTitleLabel, let itemImageView = itemImageView, let itemDonorLabel = itemDonorLabel, let currentBidLabel = currentBidLabel, let bidderSegmentedControl = bidderSegmentedControl, let biddingStatusLabel = biddingStatusLabel, let numberOfBidsLabel = numberOfBidsLabel {
        itemDescriptionLabel.text = self.item!.description
        itemTitleLabel.text = self.item!.name
        itemTitleLabel.sizeToFit()
        itemDonorLabel.text = self.item!.addedByUser

        if self.item!.imageUrl.characters.count > 0 {
          if let url = URL(string: self.item!.imageUrl) {
            URLSession.shared.dataTask(with: url) { (data, response, error) in
              if (error != nil) {
                DispatchQueue.main.async {
                  itemImageView.image = UIImage(named: "sproket")
                }
              } else if let response = response as? HTTPURLResponse, response.statusCode != 200 {
                DispatchQueue.main.async {
                  itemImageView.image = UIImage(named: "sproket")
                }
              } else if (data != nil) {
                DispatchQueue.main.async {
                  itemImageView.image = UIImage(data: data!)
                }
              }
            }.resume()
          }
        }
        if (self.item?.isLive == 1) {
          numberOfBidsLabel.text = "ATTEND LIVE AUCTION FOR BIDDING"
          currentBidLabel.text = "LIVE ITEM"
        } else {
          if (self.item!.numBids > 0) {
            currentBidLabel.text = self.item!.getWinningBidsString()
            if (self.item!.userIsWinning == true) {
              if (self.item!.userWinningBids.count == 1) {
                numberOfBidsLabel.text = "NICE! YOUR BID OF $" + String(describing: self.item!.userWinningBids.first!.amount) + " IS WINNING"
              } else {
                var numberOfBidsLabelString = "NICE! YOUR BIDS ARE WINNING ( "
                for userWinningBid in (self.item?.userWinningBids)! {
                  numberOfBidsLabelString += "$" + String(describing: userWinningBid.amount) + " "
                }
                numberOfBidsLabelString += ")"
                numberOfBidsLabel.text = numberOfBidsLabelString
              }
            } else if (self.item!.userIsOutbid == true) {
              numberOfBidsLabel.text = "YOU'VE BEEN OUTBID!"
            } else {
              numberOfBidsLabel.text = "WINNING BIDS (" + String(item!.numBids) + " total bids, " + String(self.item!.quantity) + " available)"
            }
          } else {
            numberOfBidsLabel.text = "SUGGESTED OPENING BID"
            currentBidLabel.text = "$" + String(item!.openBid)
            currentBidLabel.textColor = UIColor(red:0.26, green:0.36, blue:0.46, alpha:1.0)
          }
        }

        //bidderSegmentControl
        increments = self.item!.getIncrements()

        let attr = [NSFontAttributeName: UIFont(name: "AvenirNext-Regular", size: 18) ?? UIFont.systemFont(ofSize: 18)]
        bidderSegmentedControl.setTitleTextAttributes(attr, for: UIControlState.normal)
        bidderSegmentedControl.setTitle("$" + String(increments[0]), forSegmentAt: 0)
        bidderSegmentedControl.setTitle("$" + String(increments[1]), forSegmentAt: 1)
        bidderSegmentedControl.setTitle("$" + String(increments[2]), forSegmentAt: 2)
        bidderSegmentedControl.selectedSegmentIndex = -1

        //biddingStatusLabel

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"

        let BIDDING_OPENS = formatter.date(from: "2016/12/13 12:00")
        let BIDDING_CLOSES = formatter.date(from: "2016/12/14 19:00")
        let LIVE_BIDDING_OPENS = formatter.date(from: "2016/12/14 17:00")

        let now = NSDate()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        
        if (now.compare(BIDDING_CLOSES!) == ComparisonResult.orderedDescending) {
          bidderSegmentedControl.isEnabled = false
          bidderSegmentedControl.tintColor = UIColor(red:0.26, green:0.36, blue:0.46, alpha:1.0)
          biddingStatusLabel.text = ("Sorry, bidding has closed").uppercased()
        }
        if (self.item?.isLive == 1) {
          bidderSegmentedControl.isEnabled = false
          bidderSegmentedControl.tintColor = UIColor(red:0.26, green:0.36, blue:0.46, alpha:1.0)
          biddingStatusLabel.text = ("Bidding opens " + formatter.string(from: LIVE_BIDDING_OPENS!)).uppercased()
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
      textField.placeholder = "Minimum bid: $" + String(self.item!.getPrice())
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
    if (self.item != nil) {
      let alertController = UIAlertController(title: "Submit bid?", message: "Bid $" + String(increments[bidderSegmentedControl.selectedSegmentIndex]) + " on " + self.item!.name, preferredStyle: .alert)

      let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
        self.bidderSegmentedControl.selectedSegmentIndex = -1
      }

      let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in
        self.bidOn(item: self.item!, amount: self.increments[self.bidderSegmentedControl.selectedSegmentIndex])
        self.bidderSegmentedControl.selectedSegmentIndex = -1
      }

      alertController.addAction(cancelAction)
      alertController.addAction(OKAction)

      self.present(alertController, animated: true)
    }
  }

  func bidOn(item:Item, amount: Int){
    let user = FIRAuth.auth()?.currentUser;
    if (user != nil && self.item != nil) {
      let postRef = self.ref.child("bids").childByAutoId()
      let bidId = postRef.key
      postRef.setValue(["user": self.getUid(), "amount": amount, "item": self.item!.id] as [String : Any])
      self.ref.child("/item-bids/" + self.item!.id + "/" + bidId).setValue(["user": self.getUid(), "amount": amount] as [String : Any])
      self.ref.child("/items/" + self.item!.id + "/bids/" + bidId).setValue(true)
      self.ref.child("/users/" + self.getUid() + "/item-bids/" + self.item!.id).child(bidId).setValue(true)

      /*item.ref?.updateChildValues([
        "bids": self.item.bids.add(["email": userEmail, "name": "A HubSpotter", "amount": 50]).copy()
      ])*/
    }
  }

  func getUid() -> String {
    return (FIRAuth.auth()?.currentUser?.uid)!
  }
}
