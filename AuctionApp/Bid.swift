import Foundation

struct Bid {
  
  let id: String
  let user: String
  let amount: NSNumber
  let userInfo: User?
  let ref: FIRDatabaseReference?
  
  init(id: String, user: String, amount: NSNumber) {
    self.id = id
    self.user = user
    self.amount = amount
    self.userInfo = nil
    self.ref = nil
  }
  
  init(snapshot: FIRDataSnapshot) {
    id = snapshot.key
    let snapshotValue = snapshot.value as! [String: AnyObject]
    user = snapshotValue["user"] as! String
    amount = snapshotValue["amount"] as! NSNumber
    userInfo = nil
    ref = snapshot.ref
  }
  
  func toAnyObject() -> Any {
    return [
      "user": user,
      "amount": amount
    ]
  }
  
}
