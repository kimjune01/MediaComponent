

import UIKit

class ViewController: UIViewController {

  let mediaVC = MediaViewController()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    addMediaVC()
  }
  
  func addMediaVC() {
    self.addChildViewController(mediaVC)
    //mediaVC.view.frame = CGRectMake(x, y, width, height)
    self.view.addSubview(mediaVC.view)
    mediaVC.didMoveToParentViewController(self)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


}

