import UIKit

class ItemsTableViewController: UITableViewController, UISearchBarDelegate, ItemTableViewCellDelegate {

  @IBOutlet var searchBar: UISearchBar!

  var items: [Item] = []
  var user: User!
  var filterType: FilterType = .all
  var sizingCell: ItemTableViewCell?
  let ref = FIRDatabase.database().reference(withPath: "items")

  override func viewDidLoad() {
    super.viewDidLoad()

    ref.observe(.value, with: { snapshot in
      var newItems: [Item] = []
      for item in snapshot.children {
        let auctionItem = Item(snapshot: item as! FIRDataSnapshot)
        newItems.append(auctionItem)
      }
      self.items = newItems
      self.filterTable(self.filterType)
      // iquery?.addAscendingOrder("closetime")
      // query?.addAscendingOrder("name")
      self.tableView.reloadData()
    })

    tableView.allowsMultipleSelectionDuringEditing = false

    user = User(uid: "FakeId", email: "hungry@person.food")
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return items.count
  }

  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    //if iOS8 { 9 and up??
    //  return UITableViewAutomaticDimension
    //}else{
    if let cell = sizingCell {
      let padding = 353
      let minHeightText: NSString = "\n\n"
      let font = UIFont(name: "Avenir Light", size: 15.0)!
      let attributes =  [NSFontAttributeName: font] as NSDictionary
      let item = items[indexPath.row]

      let minSize = minHeightText.boundingRect(with: CGSize(width: (view.frame.size.width - 40), height: 1000), options: .usesLineFragmentOrigin, attributes: attributes as? [String : Any], context: nil).height

      let maxSize = item.description.boundingRect(with: CGSize(width: (view.frame.size.width - 40), height: 1000), options: .usesLineFragmentOrigin, attributes: attributes as? [String : Any], context: nil).height + 50

      return (max(minSize, maxSize) + CGFloat(padding))
    }else{
      return 392
    }
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "ItemTableViewCell", for: indexPath) as? ItemTableViewCell

    return configureCellForIndexPath(cell!, indexPath: indexPath)
  }

  func configureCellForIndexPath(_ cell: ItemTableViewCell, indexPath: IndexPath) -> ItemTableViewCell {
    let item = items[indexPath.row]
    
    //cell.itemImageView.image = nil
    // var url:URL = URL(string: item.imageUrl)!
    // cell.itemImageView.setImageWith(url)
    
    
    // let fullNameArr = item.donorName.components(separatedBy: " ")
    //cell.donorAvatar.image = nil;
    /*if fullNameArr.count > 1{
     var firstName: String = fullNameArr[0]
     var lastName: String = fullNameArr[1]
     var inital: String = firstName[0]
     var donorAvatarStringUrl = "https://api.hubapi.com/socialintel/v1/avatars?email=\(inital)\(lastName)@hubspot.com"
     
     var donorAvatarUrl:URL = URL(string: donorAvatarStringUrl)!
     
     cell.donorAvatar.setImageWith(NSURLRequest(url: donorAvatarUrl) as URLRequest, placeholderImage: nil, success: { (urlRequest, response, image) in
     cell.donorAvatar.image = image.resizedImage(to: cell.donorAvatar.bounds.size)
     
     }, failure: { (urlRequest, NSURLResponse, error) in
     print("error occured: \(error)")
     })
     }*/
    
    cell.itemDonorLabel.text = item.addedByUser
    cell.itemTitleLabel.text = item.name
    cell.itemDescriptionLabel.text = item.description
    
    /*if item.quantity > 1 {
     // var bidsString = item.currentPrice.map({bidPrice in "$\(bidPrice)"}).joined(separator: ", ")
     // if bidsString.characters.count == 0 {
     //    bidsString = "(none yet)"
     // }
     let bidsString = "(none yet)"
     cell.itemDescriptionLabel.text =
     "\(item.quantity) available! Highest \(item.quantity) bidders win. Current highest bids are \(bidsString)" +
     "\n\n" + cell.itemDescriptionLabel.text!
     }*/
    cell.delegate = self;
    cell.item = item
    
    var price: Int?
    var lowPrice: Int?
    
    price = 50 //item.price //item.currentPrice.first
    //cell.availLabel.text = "1 Available"
    
    /*switch (item.winnerType) {
     case .single:
     price = item.currentPrice.first
     cell.availLabel.text = "1 Available"
     case .multiple:
     price = item.currentPrice.first
     lowPrice = item.currentPrice.last
     cell.availLabel.text = "\(item.quantity) Available"
     }*/
    
    //let bidString = "Bid" // (item.numberOfBids == 1) ? "Bid":"Bids"
    //cell.numberOfBidsLabel.text = "1 \(bidString)" // "\(item.numberOfBids) \(bidString)"
    
    /*if let topBid = price {
     if let lowBid = lowPrice{
     if item.numberOfBids > 1{
     cell.currentBidLabel.text = "$\(lowBid)-\(topBid)"
     }else{
     cell.currentBidLabel.text = "$\(topBid)"
     }
     }else{
     cell.currentBidLabel.text = "$\(topBid)"
     }
     }else{
     cell.currentBidLabel.text = "$\(item.price)"
     }*/
    //cell.currentBidLabel.text = "$50"
    
    //cell.setWinning()
    
    /*if !item.currentWinners.isEmpty { // && item.hasBid{
     cell.setWinning()
     /*if item.isWinning{
     cell.setWinning()
     }else{
     cell.setOutbid()
     }*/
     }else{
     cell.setDefault()
     }*/
    
    /*if(item.closeTime.timeIntervalSinceNow < 0.0){
     cell.dateLabel.text = "Sorry, bidding has closed"
     cell.bidNowButton.isHidden = true
     }else{
     if(item.openTime.timeIntervalSinceNow < 0.0){
     //open
     cell.dateLabel.text = "Bidding closes \((item.closeTime as NSDate).relativeTime().lowercased())."
     cell.bidNowButton.isHidden = false
     }else{
     cell.dateLabel.text = "Bidding opens \((item.openTime as NSDate).relativeTime().lowercased())."
     cell.bidNowButton.isHidden = true
     }
     }*/
    
    return cell
  }

  
  override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
  }

  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      items.remove(at: indexPath.row)
      tableView.reloadData()
    }
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let cell = tableView.cellForRow(at: indexPath) else { return }
    var item = items[indexPath.row]
    print(item)
    //tableView.reloadData()
  }

  /*func searchForQuery(_ query: String) -> ([Item]) {
    return applyFilter(.search(searchTerm: query))
  }*/

  func cellDidPressBid(_ item: Item) {
    
    /*let bidVC = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "BiddingViewController") as? BiddingViewController
    if let biddingVC = bidVC {
      biddingVC.delegate = self
      biddingVC.item = item
      addChildViewController(biddingVC)
      view.addSubview(biddingVC.view)
      biddingVC.didMove(toParentViewController: self)
    }*/
    print(item)
  }
  
  func applyFilter(_ filter: FilterType) -> ([Item]) {
    print("APPLY FILTER")
    return items.filter({ (item) -> Bool in
      print(item.name)
      return filter.predicate.evaluate(with: item)
    })
  }

  func filterTable(_ filter: FilterType) {
    filterType = filter
    self.items = applyFilter(filter)
    self.tableView.reloadData()
  }

  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    if searchText.isEmpty {
      filterTable(.all)
    }else{
      filterTable(.search(searchTerm:searchText))
    }
  }

  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    // self.segmentBarValueChanged(segmentControl)
    searchBar.resignFirstResponder()
  }

}

enum FilterType: CustomStringConvertible {
  case all
  case noBids
  case myItems
  case search(searchTerm: String)

  var description: String {
    switch self{
    case .all:
      return "All"
    case .noBids:
      return "NoBids"
    case .myItems:
      return "My Items"
    case .search:
      return "Searching"
    }
  }

  var predicate: NSPredicate {
    switch self {
    case .all:
      return NSPredicate(value: true)
    case .noBids:
      return NSPredicate(block: {(object, bindings) -> Bool in
        /*if let item = object as? Item {
         return true //item.numberOfBids == 0
         }*/
        return false
      })
    case .myItems:
      return NSPredicate(block: {(object, bindings) -> Bool in
        if (object as? Item) != nil {
          return false //item.hasBid
        }
        return false
      })

    case .search(let searchTerm):
      print("SEARCH TERM")
      print(searchTerm)
      // return NSPredicate(format: "(name CONTAINS[c] %@) OR (addedByUser CONTAINS[c] %@) OR (description CONTAINS[c] %@)", searchTerm)
      return NSPredicate(format: "name CONTAINS[c] %@", searchTerm)
    default:
      return NSPredicate(value: true)
    }
  }
}
