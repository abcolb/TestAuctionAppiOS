//
//  ItemTableViewCell.swift
//  AuctionApp
//

import UIKit
import Foundation

class ItemTableViewCell: UITableViewCell {
  
  @IBOutlet var cardContainer: UIView!
  @IBOutlet var itemDescriptionLabel: UILabel!
  @IBOutlet var itemTitleLabel: UILabel!
  @IBOutlet var itemImageView: UIImageView!
  @IBOutlet var itemDonorLabel: UILabel!
  @IBOutlet var numAvailableLabel: UILabel!
  @IBOutlet var suggestedActionLabel: UILabel!
  var alreadyLoaded: Bool!
  
  var item: Item?
  override func awakeFromNib() {
    super.awakeFromNib()

    alreadyLoaded = false
    cardContainer.layer.cornerRadius = 4
    cardContainer.clipsToBounds = true
  }
  
  func setWinning(){
    suggestedActionLabel.textColor = UIColor(red:0.00, green:0.64, blue:0.74, alpha:1.0)
    suggestedActionLabel.text = "WINNING"
  }
  
  func setOutbid(){
    suggestedActionLabel.textColor = UIColor(red:0.95, green:0.33, blue:0.36, alpha:1.0)
    suggestedActionLabel.text = "OUTBID!"
  }
  
  func setShouldBid(){
    suggestedActionLabel.textColor = UIColor(red:1.00, green:0.56, blue:0.35, alpha:1.0)
    suggestedActionLabel.text = "BID NOW"
  }
  
  func setBiddingDisabled() {
    suggestedActionLabel.text = ""
  }
  
  func setBidStatus(){
    if (self.item!.getIsBiddingOpen() != true) {
      self.setBiddingDisabled()
    } else if (self.item!.userIsOutbid == true) {
      self.setOutbid()
    } else if (self.item!.userIsWinning == true) {
      self.setWinning()
    } else {
      self.setShouldBid()
    }
  }
  
}
