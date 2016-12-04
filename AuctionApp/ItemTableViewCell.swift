//
//  ItemTableViewCell.swift
//  AuctionApp
//

import UIKit
import Foundation

protocol ItemTableViewCellDelegate {
  
  func cellDidPressBid(_ item: Item)
  
}

class ItemTableViewCell: UITableViewCell {
  
  @IBOutlet var cardContainer: UIView!
  @IBOutlet var itemDescriptionLabel: UILabel!
  @IBOutlet var itemTitleLabel: UILabel!
  @IBOutlet var itemImageView: UIImageView!
  @IBOutlet var itemDonorLabel: UILabel!
  @IBOutlet var numAvailableLabel: UILabel!
  @IBOutlet var suggestedActionLabel: UILabel!
  var alreadyLoaded: Bool!
  
  var delegate: ItemTableViewCellDelegate?
  var item: Item?
  override func awakeFromNib() {
    super.awakeFromNib()

    alreadyLoaded = false
    cardContainer.layer.cornerRadius = 4
    cardContainer.clipsToBounds = true
  }
  
  func setWinning(){
    suggestedActionLabel.textColor = UIColor(red:0.95, green:0.33, blue:0.49, alpha:1.0)
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
  
  func setNoBids() {
    suggestedActionLabel.text = ""
  }
  
}
