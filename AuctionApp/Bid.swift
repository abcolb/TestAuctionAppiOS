import Foundation

struct Bid {
  
  let id: String
  let name: String
  let email: String
  let item: String
  let amount: NSNumber
  let ref: FIRDatabaseReference?
  
  init(name: String, email: String, item: String, amount: NSNumber, id: String = "") {
    self.id = id
    self.name = name
    self.email = email
    self.item = item
    self.amount = amount
    self.ref = nil
  }
  
  init(snapshot: FIRDataSnapshot) {
    id = snapshot.key
    let snapshotValue = snapshot.value as! [String: AnyObject]
    name = snapshotValue["name"] as! String
    email = snapshotValue["email"] as! String
    item = snapshotValue["email"] as! String
    amount = snapshotValue["amount"] as! NSNumber
    ref = snapshot.ref
  }
  
  func toAnyObject() -> Any {
    return [
      "name": name,
      "email": email,
      "item": item,
      "amount": amount
    ]
  }
  
}
