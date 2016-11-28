//
//  ItemDetailViewController.swift
//  AuctionApp
//
//

import UIKit
import Foundation

class ItemDetailViewController: UIViewController {
  
  //@IBOutlet var dateLabel: UILabel!
  //@IBOutlet var shadowView: UIView!
  //@IBOutlet var moreInfoLabel: UILabel!
  //@IBOutlet var moreInfoView: UIView!
  @IBOutlet var itemDescriptionLabel: UILabel!
  @IBOutlet var itemTitleLabel: UILabel!
  @IBOutlet var itemImageView: UIImageView!
  @IBOutlet var currentBidLabel: UILabel!
  //@IBOutlet var numberOfBidsLabel: UILabel!
  @IBOutlet var itemDonorLabel: UILabel!
  @IBOutlet var bidderSegmentedControl: UISegmentedControl!
  //@IBOutlet var headerBackground: UIView!
  @IBOutlet var numAvailableLabel: UILabel!
  
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
        
        currentBidLabel.text = "$50"
        
        let attr = [NSFontAttributeName: UIFont(name: "Avenir Next", size: 24) ?? UIFont.systemFont(ofSize: 17)]
        bidderSegmentedControl.setTitleTextAttributes(attr, for: UIControlState.normal)
        bidderSegmentedControl.setTitle("+$10", forSegmentAt: 0)
        bidderSegmentedControl.setTitle("+$25", forSegmentAt: 1)
        bidderSegmentedControl.setTitle("+$50", forSegmentAt: 2)
        bidderSegmentedControl.selectedSegmentIndex = -1
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
    let alertController = UIAlertController(title: "Submit bid?", message: "Bid $50 on 4-6 packs of Reinbeer.", preferredStyle: .alert)
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
      // ...
    }
    alertController.addAction(cancelAction)
    
    let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in
      // ...
    }
    alertController.addAction(OKAction)
    
    self.present(alertController, animated: true) {
      // ...
    }
  }
}

