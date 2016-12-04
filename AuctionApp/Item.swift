import Foundation

struct Item {

  let id: String
  let name: String
  let addedByUser: String
  let description: String
  let imageUrl: String
  let quantity: Int
  let openBid: Int
  let isLive: Bool
  let bids: [String]
  let ref: FIRDatabaseReference?

  init(name: String, addedByUser: String, description: String, imageUrl: String, quantity: Int, openBid: Int, isLive: Bool, bids: [String], key: String = "") {
    self.id = key
    self.name = name
    self.addedByUser = addedByUser
    self.description = description
    self.imageUrl = imageUrl
    self.quantity = quantity
    self.openBid = openBid
    self.isLive = isLive
    self.bids = bids
    self.ref = nil
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
    isLive = snapshotValue["islive"] as! Bool
    var bidsFound : [String] = []
    if snapshotValue["bids"] != nil {
      let result = snapshotValue["bids"] as! NSMutableDictionary
      for bid in result {
        bidsFound.append(bid.key as! String)
      }
    }
    bids = bidsFound
    ref = snapshot.ref
  }

  func toAnyObject() -> Any {
    return [
      "name": name,
      "addedByUser": addedByUser,
      "description": description,
      "imageUrl": imageUrl,
      "quantity": quantity,
      "openBid": openBid,
      "quantity": quantity,
      "isLive": isLive,
      "bids": bids
    ]
  }
  
  func getPrice() -> Int {
    if (bids.count > 0){
      return 500 //new Bid(bids.first
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
    
    let priceIncrements = BIDDING_INCREMENTS[self.getBidType()]

    return [priceIncrements![0] + self.getPrice(), priceIncrements![1] + self.getPrice(), priceIncrements![2] + self.getPrice()]
  }

}
