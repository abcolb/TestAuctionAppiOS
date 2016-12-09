import UIKit
import Firebase

class MyBidsListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
  var ref: FIRDatabaseReference!
  var items: [Item] = []
  
  @IBOutlet weak var tableView: UITableView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    ref = FIRDatabase.database().reference()
    
    let user = FIRAuth.auth()?.currentUser
    if (user != nil) {
      //let userID = user?.uid
      
      ref.child("items").observe(.value, with: { snapshot in
        var newItems: [Item] = []
        for item in snapshot.children {
          let auctionItem = Item(snapshot: item as! FIRDataSnapshot)
          newItems.append(auctionItem)
        }
        self.items = newItems
        self.tableView.reloadData()
      })
    }
    
    let button = UIButton(type: UIButtonType.custom)
    button.setImage(UIImage(named: "HSLogOutIcon"), for: UIControlState.normal)
    button.addTarget(self, action: #selector(logOutPressed), for: UIControlEvents.touchUpInside)
    button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
    
    tableView.delegate = self
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.items.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "ItemTableViewCell", for: indexPath) as? ItemTableViewCell
    
    return configureCellForIndexPath(cell!, indexPath: indexPath)
  }
  
  func configureCellForIndexPath(_ cell: ItemTableViewCell, indexPath: IndexPath) -> ItemTableViewCell {
    let item = self.items[indexPath.row]
    
    cell.itemImageView.image = UIImage(named: "sproket")
    cell.itemDonorLabel.text = item.addedByUser
    cell.itemTitleLabel.text = item.name
    cell.itemDescriptionLabel.text = item.description
    cell.numAvailableLabel.text = String(item.quantity) + " Available"
    
    if item.imageUrl.characters.count > 0 {
      if let url = URL(string: item.imageUrl) {
        URLSession.shared.dataTask(with: url) { (data, response, error) in
          if (error != nil) {
            DispatchQueue.main.async {
              cell.itemImageView.image = UIImage(named: "sproket")
            }
          } else if let response = response as? HTTPURLResponse, response.statusCode != 200 {
            DispatchQueue.main.async {
              cell.itemImageView.image = UIImage(named: "sproket")
            }
          } else if (data != nil) {
            DispatchQueue.main.async {
              cell.itemImageView.image = UIImage(data: data!)
            }
          }
          }.resume()
      }
    }
    
    cell.item = item
    cell.setBidStatusString(bidStatus: self.getBidStatus(item: item))
    return cell
  }
  
  func logOutPressed(_ sender: UIButton) {
    let firebaseAuth = FIRAuth.auth()
    do {
      try firebaseAuth?.signOut()
      dismiss(animated: true, completion: nil)
    } catch let signOutError as NSError {
      print ("Error signing out:", signOutError.localizedDescription)
    }
  }
  
  func getBidStatus(item: Item) -> String {
    if (!item.getIsBiddingOpen()) {
      return "NO_BIDS"
    } else if (false) {
      return "OUTBID"
    } else if (item.getIsUserWinning()) {
      return "WINNING"
    } else {
      return "SHOULD_BID"
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    self.tableView.reloadData()
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    performSegue(withIdentifier: "detail", sender: indexPath)
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 100
  }
  
  func getUid() -> String {
    return (FIRAuth.auth()?.currentUser?.uid)!
  }
  
  func getQuery() -> FIRDatabaseQuery {
    return self.ref
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard let path: IndexPath = sender as? IndexPath else { return }
    guard let detail: ItemDetailViewController = segue.destination as? ItemDetailViewController else {
      return
    }
    detail.detailItem = self.items[path.item]
    detail.hidesBottomBarWhenPushed = true
  }
}
