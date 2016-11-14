import Foundation

struct Item {

  let key: String
  let name: String
  let addedByUser: String
  let description: String
  let ref: FIRDatabaseReference?
  var completed: Bool

  init(name: String, addedByUser: String, description: String, completed: Bool, key: String = "") {
    self.key = key
    self.name = name
    self.addedByUser = addedByUser
    self.description = description
    self.completed = completed
    self.ref = nil
  }

  init(snapshot: FIRDataSnapshot) {
    key = snapshot.key
    let snapshotValue = snapshot.value as! [String: AnyObject]
    name = snapshotValue["shortname"] as! String
    addedByUser = snapshotValue["donorname"] as! String
    description = snapshotValue["longname"] as! String
    completed = true // snapshotValue["completed"] as! Bool
    ref = snapshot.ref
  }

  func toAnyObject() -> Any {
    return [
      "name": name,
      "addedByUser": addedByUser,
      "description": description,
      "completed": completed
    ]
  }

}
