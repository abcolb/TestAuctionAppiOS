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
  var numBids: Int
  var winningBids: [Bid] = []
  var userIsWinning: Bool
  var userIsOutbid: Bool

  init(name: String, addedByUser: String, description: String, imageUrl: String, quantity: Int, openBid: Int, isLive: Bool, numBids: Int, key: String = "") {
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
          print("BID", bid)
          winningBidsFound.append(bid)
        }
      })
      winningBids = winningBidsFound;
    } else {
      winningBids = winningBidsFound;
    }
  }
  
  func getPrice() -> Int {
    if (numBids > 0) {
      return 500;
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

  func getIsBiddingOpen() -> Bool {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy/MM/dd HH:mm"
    // SMOKE TEST DATA
    // let BIDDING_OPENS = formatter.date(from: "2016/12/7 15:00")
    let BIDDING_OPENS = formatter.date(from: "2016/12/6 15:00")
    let BIDDING_CLOSES = formatter.date(from: "2016/12/7 20:00")
    let LIVE_BIDDING_OPENS = formatter.date(from: "2016/12/7 17:00")
    
    // LIVE AUCTION DATA
    // let BIDDING_OPENS = formatter.date(from: "2016/12/12 15:00")
    // let BIDDING_CLOSES = formatter.date(from: "2016/12/14 20:00")
    // let LIVE_BIDDING_OPENS = formatter.date(from: "2016/12/14 17:00")
    
    let now = NSDate()
    
    if (now.compare(BIDDING_CLOSES!) == ComparisonResult.orderedDescending) {
      return false
    }
    if (isLive) {
      if (now.compare(LIVE_BIDDING_OPENS!) != ComparisonResult.orderedDescending) {
        return false
      }
    } else {
      if (now.compare(BIDDING_OPENS!) != ComparisonResult.orderedDescending) {
        return false
      }
    }
    return true
  }
  
  func getIsUserWinning() -> Bool {
    //item.bids.first.email == user.email) {
    return winningBids.count > 0 //numBids > 0
  }
  
  func getBidStatus() -> String {
    
    if (!getIsBiddingOpen()) {
      return "NO_BIDS"
    } else if (false) {
      return "OUTBID"
    } else if (getIsUserWinning()) {
      return "WINNING"
    } else {
      return "SHOULD_BID"
    }
  }
  
  func getWinningBidsString() -> String {
    var winningBidsString = ""
    for bid in winningBids {
      print("BID", bid.amount)
      winningBidsString += String(describing: bid.amount) + " "
    }
    return winningBidsString
  }
  
}

/*
 
 /*if (bid.user == userID){
 userIsWinning = true
 }*/
 /*if (winningBids.count > 0) {
 FIRDatabase.database().reference().child("users").child(userID!).child("item-bids").child(auctionItem.id).observeSingleEvent(of: .value, with: { (snapshot) in
 for _ in snapshot.children {
 if (!userIsWinning) {
 userIsOutbid = true;
 }
 }
 })
 }*/


/*public void onDataChange(DataSnapshot dataSnapshot) {
 mItem = dataSnapshot.getValue(Item.class);
 mNameView.setText(mItem.getName());
 mDonorView.setText(mItem.getDonorname());
 mNumAvailableView.setText(String.valueOf(mItem.getQty()) + " Available");
 mDescriptionView.setText(mItem.getDescription());
 
 Picasso.with(getBaseContext())
 .load(mItem.getImageurl())
 .placeholder(R.drawable.ic_item_image)
 .error(R.drawable.ic_item_image)
 .into(mImageView);
 
 Integer numBids = mItem.getNumBids();
 mSuggestedBids = new ArrayList<>();
 mMinBid = null;
 if (numBids == 0) {
 mNumBidsView.setText("SUGGESTED OPENING BID");
 mWinningBidsView.setText("$" + String.valueOf(mItem.openbid));
 mWinningBidsView.setTextColor(Color.parseColor("#425b76"));
 mMinBid = mItem.openbid;
 if (mMinBid < 50) {
 mSuggestedBids.add(mMinBid + 1);
 mSuggestedBids.add(mMinBid + 5);
 mSuggestedBids.add(mMinBid + 10);
 } else if (mMinBid < 100) {
 mSuggestedBids.add(mMinBid + 5);
 mSuggestedBids.add(mMinBid + 10);
 mSuggestedBids.add(mMinBid + 25);
 } else {
 mSuggestedBids.add(mMinBid + 10);
 mSuggestedBids.add(mMinBid + 25);
 mSuggestedBids.add(mMinBid + 50);
 }
 mBidButtonLow.setText("$" + mSuggestedBids.get(0));
 mBidButtonMid.setText("$" + mSuggestedBids.get(1));
 mBidButtonHigh.setText("$" + mSuggestedBids.get(2));
 }
 
 mWinningBids = new ArrayList<>();
 String mWinningBidsString = "";
 Query winningBidsQuery = mItemBidsReference.limitToLast(mItem.getQty());
 winningBidsQuery.addListenerForSingleValueEvent(
 new ValueEventListener() {
 @Override
 public void onDataChange(DataSnapshot dataSnapshot) {
 Log.e("Count ", "" + dataSnapshot.getChildrenCount());
 for (DataSnapshot bidSnapshot : dataSnapshot.getChildren()) {
 Bid bid = bidSnapshot.getValue(Bid.class);
 mWinningBids.add(bid);
 if (bid.user.equals(getUid())) {
 mUserIsWinning = true;
 mWinningBid = bid.amount;
 }
 }
 if (mWinningBids.size() > 0) {
 
 mUserBidsReference.addListenerForSingleValueEvent(
 new ValueEventListener() {
 @Override
 public void onDataChange(DataSnapshot dataSnapshot) {
 if (dataSnapshot.getChildrenCount() > 0 && !mUserIsWinning) {
 mUserIsOutbid = true;
 }
 
 String winningBidsString = "";
 for (Bid bid : mWinningBids) {
 if (mMinBid == null || mMinBid > bid.amount) {
 mMinBid = bid.amount;
 }
 winningBidsString = winningBidsString.concat("$" + String.valueOf(bid.amount) + " ");
 }
 
 if (mUserIsWinning) {
 if (mItem.getQty() > 1) {
 mNumBidsView.setText("NICE! YOUR BID IS WINNING");
 } else {
 mNumBidsView.setText("NICE! YOUR BID OF $" + mWinningBid + " IS WINNING");
 }
 } else if (mUserIsOutbid) {
 mNumBidsView.setText("YOU'VE BEEN OUTBID!");
 } else {
 mNumBidsView.setText("WINNING BIDS (" + String.valueOf(mItem.bids.size()) + " total bids)");
 }
 mWinningBidsView.setText(winningBidsString);
 mWinningBidsView.setTextColor(Color.parseColor("#ff8f59"));
 
 if (mMinBid < 50) {
 mSuggestedBids.add(mMinBid + 1);
 mSuggestedBids.add(mMinBid + 5);
 mSuggestedBids.add(mMinBid + 10);
 } else if (mMinBid < 100) {
 mSuggestedBids.add(mMinBid + 5);
 mSuggestedBids.add(mMinBid + 10);
 mSuggestedBids.add(mMinBid + 25);
 } else {
 mSuggestedBids.add(mMinBid + 10);
 mSuggestedBids.add(mMinBid + 25);
 mSuggestedBids.add(mMinBid + 50);
 }
 
 mBidButtonLow.setText("$" + mSuggestedBids.get(0));
 mBidButtonMid.setText("$" + mSuggestedBids.get(1));
 mBidButtonHigh.setText("$" + mSuggestedBids.get(2));
 }
 
 @Override
 public void onCancelled(DatabaseError firebaseError) {
 Log.e("The read failed: ", firebaseError.getMessage());
 }
 });
 
 }
 }
 
 @Override
 public void onCancelled(DatabaseError firebaseError) {
 Log.e("The read failed: ", firebaseError.getMessage());
 }
 }
 );
 
 Date now = new Date();
 
 // SMOKE TEST DATA
 // Date BIDDING_OPENS = new Date(1481130000000L); // "2016/12/6 12:00"
 Date BIDDING_OPENS = new Date(1480957200000L); // "2016/12/7 12:00"
 Date BIDDING_CLOSES = new Date(1481151600000L); // "2016/12/7 18:00"
 Date LIVE_BIDDING_OPENS = new Date(1481140800000L); //"2016/12/7 15:00"
 
 // LIVE AUCTION DATA
 // Date BIDDING_OPENS = new Date(1481292000000L); // "2016/12/9 9:00"
 // Date BIDDING_CLOSES = new Date(1481763600000L); // "2016/12/14 20:00"
 // Date LIVE_BIDDING_OPENS = new Date(1481752800000L); //"2016/12/14 17:00"
 
 SimpleDateFormat sdf = new SimpleDateFormat("MM/dd HH:mm");
 
 Log.d("BIDDING_CLOSES", sdf.format(BIDDING_CLOSES));
 Log.d("BIDDING AVAILABLE", String.valueOf(now.before(BIDDING_CLOSES)));
 
 if (now.after(BIDDING_CLOSES)) {
 mBidButtonLow.setEnabled(false);
 mBidButtonMid.setEnabled(false);
 mBidButtonHigh.setEnabled(false);
 mBidButtonCustom.setEnabled(false);
 mBiddingStatusView.setText("SORRY, BIDDING HAS CLOSED");
 } else if (mItem.getIslive()) {
 if (now.after(LIVE_BIDDING_OPENS)) {
 mBiddingStatusView.setText("BIDDING CLOSES " + sdf.format(BIDDING_CLOSES));
 } else {
 mBidButtonLow.setEnabled(false);
 mBidButtonMid.setEnabled(false);
 mBidButtonHigh.setEnabled(false);
 mBidButtonCustom.setEnabled(false);
 mBiddingStatusView.setText("BIDDING OPENS " + sdf.format(LIVE_BIDDING_OPENS));
 }
 } else {
 if (now.after(BIDDING_OPENS)) {
 mBiddingStatusView.setText("BIDDING CLOSES " + sdf.format(BIDDING_CLOSES));
 } else {
 mBidButtonLow.setEnabled(false);
 mBidButtonMid.setEnabled(false);
 mBidButtonHigh.setEnabled(false);
 mBidButtonCustom.setEnabled(false);
 mBiddingStatusView.setText("BIDDING OPENS " + sdf.format(BIDDING_OPENS));
 }
 }
 }*/*/
