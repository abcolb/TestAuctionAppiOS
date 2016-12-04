import UIKit

class LoginViewController: UIViewController {
  
  // let ref = FIRDatabase.database().reference()
  let loginToList = "LoginToList"
  
  @IBOutlet weak var emailTextField: UITextField!
  @IBOutlet weak var passwordTextField: UITextField!
  
  func signedIn(_ user: FIRUser?) {
    // tell app we're logged in
    performSegue(withIdentifier: loginToList, sender: nil)
  }
   
  func setDisplayName(_ user: FIRUser) {
   let changeRequest = user.profileChangeRequest()
   changeRequest.displayName = user.email!.components(separatedBy: "@")[0]
   changeRequest.commitChanges(){ (error) in
    if let error = error {
      print(error.localizedDescription)
      return
    }
    self.signedIn(FIRAuth.auth()?.currentUser)
   }
  }
  
  @IBAction func loginDidTouch(_ sender: AnyObject) {
    guard let email = emailTextField.text, let password = passwordTextField.text else { return }
    FIRAuth.auth()?.signIn(withEmail: email, password: password) { (user, error) in
     if let error = error {
      print(error.localizedDescription)
      return
     }
     self.signedIn(user!)
    }
    print("click")
  }
  
  @IBAction func signUpDidTouch(_ sender: AnyObject) {
    guard let email = emailTextField.text, let password = passwordTextField.text else { return }
    FIRAuth.auth()?.createUser(withEmail: email, password: password) { (user, error) in
      if let error = error {
        print(error.localizedDescription)
        return
      }
      let userData = ["email": email, "name": "A HubSpotter"] as [String : String]
      // self.ref.child("users").child(email).setValue(userData)
      self.setDisplayName(user!)
    }
    print("click")
  }
  
  override func viewDidAppear(_ animated: Bool) {
   if let user = FIRAuth.auth()?.currentUser {
    self.signedIn(user)
   }
  }
}

extension LoginViewController: UITextFieldDelegate {
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if textField == emailTextField {
      passwordTextField.becomeFirstResponder()
    }
    if textField == passwordTextField {
      textField.resignFirstResponder()
    }
    return true
  }
}
