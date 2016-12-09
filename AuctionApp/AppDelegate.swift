import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]? = [:]) -> Bool {
    UIApplication.shared.statusBarStyle = .lightContent
    
    /*UITabBar.appearance().barTintColor = UIColor(red:0.26, green:0.36, blue:0.46, alpha:1.0)
    
    let colorNormal : UIColor = UIColor(red:0.80, green:0.84, blue:0.89, alpha:1.0)
    let colorSelected : UIColor = UIColor.white
    let titleFontAll : UIFont = UIFont(name: "AvenirNext-Regular", size: 10.0)!
    
    let attributesNormal = [
      NSForegroundColorAttributeName : colorNormal,
      NSFontAttributeName : titleFontAll
    ]
    
    let attributesSelected = [
      NSForegroundColorAttributeName : colorSelected,
      NSFontAttributeName : titleFontAll
    ]
    
    UITabBarItem.appearance().setTitleTextAttributes(attributesNormal, for: .normal)
    UITabBarItem.appearance().setTitleTextAttributes(attributesSelected, for: .selected)*/
    
    FIRApp.configure()
    FIRDatabase.database().persistenceEnabled = true
    return true
  }

}
