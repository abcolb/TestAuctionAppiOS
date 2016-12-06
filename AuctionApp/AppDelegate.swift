import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]? = [:]) -> Bool {
    UIApplication.shared.statusBarStyle = .lightContent
    FIRApp.configure()
    FIRDatabase.database().persistenceEnabled = true
    return true
  }

}
