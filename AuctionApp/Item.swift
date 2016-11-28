import Foundation

struct Item {

  let key: String
  let name: String
  let addedByUser: String
  let description: String
  let imageUrl: String
  let quantity: NSNumber
  let ref: FIRDatabaseReference?

  init(name: String, addedByUser: String, description: String, imageUrl: String, quantity: NSNumber, key: String = "") {
    self.key = key
    self.name = name
    self.addedByUser = addedByUser
    self.description = description
    self.imageUrl = imageUrl
    self.quantity = quantity
    self.ref = nil
  }

  init(snapshot: FIRDataSnapshot) {
    key = snapshot.key
    let snapshotValue = snapshot.value as! [String: AnyObject]
    name = snapshotValue["shortname"] as! String
    addedByUser = snapshotValue["donorname"] as! String
    description = snapshotValue["longname"] as! String
    imageUrl = snapshotValue["imageurl"] as! String
    quantity = snapshotValue["qty"] as! NSNumber
    ref = snapshot.ref
  }

  func toAnyObject() -> Any {
    return [
      "name": name,
      "addedByUser": addedByUser,
      "description": description,
      "imageUrl": imageUrl,
      "quantity": quantity
    ]
  }

}
