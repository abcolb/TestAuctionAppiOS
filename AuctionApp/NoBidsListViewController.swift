import UIKit
import Firebase

class NoBidsListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
  var ref: FIRDatabaseReference!
  var items: [Item] = []
  
  @IBOutlet weak var tableView: UITableView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    ref = FIRDatabase.database().reference()
    
    let user = FIRAuth.auth()?.currentUser
    if (user != nil) {
      ref.child("items").observe(.value, with: { snapshot in
        self.items = []
        for auctionItem in snapshot.children.allObjects as! [FIRDataSnapshot] {
          let dict = auctionItem.value as! Dictionary<String, AnyObject>
          if dict["bids"] == nil {
            let auctionItem = Item(snapshot: auctionItem)
            self.items.append(auctionItem)
            self.tableView.reloadData()
          }
        }
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
    if (self.items.count < 1) {
      let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
      messageLabel.text = "Awesome, all items have bids!\nCheck out My Bids to see if you've been outbid"
      messageLabel.textColor = UIColor(red:0.26, green:0.36, blue:0.46, alpha:1.0)
      messageLabel.numberOfLines = 0;
      messageLabel.textAlignment = .center;
      messageLabel.font = UIFont(name: "AvenirNext-Regular", size: 15.0)
      messageLabel.sizeToFit()
      
      tableView.backgroundView = messageLabel;
      tableView.separatorStyle = .none;
      return 0;
    } else {
      return self.items.count
    }
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
    cell.setBidStatus()
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
    detail.itemKey = self.items[path.item].id
    detail.hidesBottomBarWhenPushed = true
  }
}
