import Foundation

struct Item {

  let id: String
  let name: String
  let addedByUser: String
  let description: String
  let imageUrl: String
  let quantity: Int
  let openBid: Int
  let isLive: Int
  var numBids: Int
  var winningBids: [Bid] = []
  var userIsWinning: Bool
  var userIsOutbid: Bool
  var userWinningBid: Bid?

  init(name: String, addedByUser: String, description: String, imageUrl: String, quantity: Int, openBid: Int, isLive: Int, numBids: Int, winningBids: [Bid], userWinningBid: Bid, key: String = "") {
    self.id = key
    self.name = name
    self.addedByUser = addedByUser
    self.description = description
    self.imageUrl = imageUrl
    self.quantity = quantity
    self.openBid = openBid
    self.isLive = isLive
    self.numBids = numBids
    self.winningBids = []
    self.userIsWinning = false
    self.userIsOutbid = false
    self.userWinningBid = userWinningBid
  }

  init(snapshot: FIRDataSnapshot) {
    id = snapshot.key
    let snapshotValue = snapshot.value as! [String: AnyObject]
    name = snapshotValue["name"] as! String
    addedByUser = snapshotValue["donorname"] as! String
    description = snapshotValue["description"] as! String
    imageUrl = snapshotValue["imageurl"] as! String
    quantity = snapshotValue["qty"] as! Int
    openBid = snapshotValue["openbid"] as! Int
    isLive = snapshotValue["islive"] as! Int
    
    userIsOutbid = false
    userIsWinning = false
    
    if snapshotValue["bids"] != nil {
      numBids = (snapshotValue["bids"] as! NSDictionary).count
    } else {
      numBids = 0
    }
  
    var winningBidsFound: [Bid] = []
    if numBids > 0 {
      let winningBidsQuery = FIRDatabase.database().reference().child("item-bids").child(id).queryLimited(toLast: UInt(quantity));
      winningBidsQuery.observeSingleEvent(of: .value, with: { (snapshot) in
        for child in snapshot.children {
          let bid = Bid(snapshot: child as! FIRDataSnapshot)
          /*let userInfoQuery = FIRDatabase.database().reference().child("users").child(bid.user)
          userInfoQuery.observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists(){
              bid.userInfo = User(snapshot: snapshot)
            }*/
          winningBidsFound.append(bid)
          //})
        }
      })
      winningBids = winningBidsFound;
    } else {
      winningBids = winningBidsFound;
    }
  }
  
  func getPrice() -> Int {
    if (self.winningBids.count > 0) {
      return Int(self.winningBids.last!.amount)
    }
    return self.openBid
  }
  
  func getBidType() -> String {
    let currentPrice = self.getPrice()
    if (currentPrice < 50) {
      return "SMALL"
    } else if (currentPrice < 100) {
      return "MEDIUM"
    } else {
      return "LARGE"
    }
  }
  
  func getIncrements() -> [Int] {
    
    let BIDDING_INCREMENTS : [String: [Int]] = [
      "SMALL": [1, 5, 10],
      "MEDIUM": [5, 10, 25],
      "LARGE": [10, 25, 50]
    ]
  
    let priceIncrements = BIDDING_INCREMENTS[self.getBidType()]!
    return priceIncrements.map{$0 + self.getPrice()}
  }

  func getIsBiddingOpen() -> Bool {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy/MM/dd HH:mm"
    
    // let BIDDING_OPENS = formatter.date(from: "2016/12/13 12:00")
    let BIDDING_OPENS = formatter.date(from: "2016/12/11 12:00")
    let BIDDING_CLOSES = formatter.date(from: "2016/12/14 19:00")
    
    let now = NSDate()
    
    if (isLive == 1) {
      return false
    }
    
    if (now.compare(BIDDING_CLOSES!) == ComparisonResult.orderedDescending) {
      return false
    } else {
      if (now.compare(BIDDING_OPENS!) != ComparisonResult.orderedDescending) {
        return false
      }
    }
    return true
  }
  
  func getWinningBidsString() -> String {
    var winningBidsString = ""
    for bid in self.winningBids {
      winningBidsString += "$" + String(describing: bid.amount) + " (" + String(describing: bid.user) + ")"
    }
    return winningBidsString
  }
}
