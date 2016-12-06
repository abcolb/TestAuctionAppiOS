import UIKit

class LoginViewController: UIViewController {
  
  let loginToList = "LoginToList"
  
  @IBOutlet weak var emailTextField: UITextField!
  @IBOutlet weak var passwordTextField: UITextField!
  
  func signedIn(_ user: FIRUser?) {
    performSegue(withIdentifier: loginToList, sender: nil)
  }
  
  func setDisplayName(_ user: FIRUser) {
    
    let alertController = UIAlertController(title: "What should we call you?", message: "", preferredStyle: .alert)
    
    alertController.addTextField { (textField : UITextField!) -> Void in
      textField.placeholder = "First name"
    }
    alertController.addTextField { (textField : UITextField!) -> Void in
      textField.placeholder = "Second name"
    }
    
    let saveAction = UIAlertAction(title: "Save", style: .default, handler: { alert -> Void in
      let firstTextField = alertController.textFields![0] as UITextField
      let secondTextField = alertController.textFields![1] as UITextField
      if (firstTextField.text!.characters.count > 0 && secondTextField.text!.characters.count > 0 ) {
        let userData = ["email": user.email!, "firstname": firstTextField.text!, "lastname": secondTextField.text!] as [String : String]
        FIRDatabase.database().reference().child("users").child(user.uid).setValue(userData)
        self.signedIn(user)
      }
    })
    
    alertController.addAction(saveAction)
    self.present(alertController, animated: true, completion: nil)
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
  }
  
  @IBAction func signUpDidTouch(_ sender: AnyObject) {
    guard let email = emailTextField.text, let password = passwordTextField.text else { return }
    FIRAuth.auth()?.createUser(withEmail: email, password: password) { (user, error) in
      if let error = error {
        print(error.localizedDescription)
        return
      }
      self.setDisplayName(user!)
    }
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
