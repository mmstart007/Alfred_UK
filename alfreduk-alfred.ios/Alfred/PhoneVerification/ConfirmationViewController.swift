//
//  ConfirmationViewController.swift
//  Alfred
//
//  Created by Miguel Angel Carvajal on 1/7/16.
//  Copyright © 2016 A Ascendanet Sun. All rights reserved.
//

import UIKit

class ConfirmationViewController: UIViewController {
    
   

    override func viewDidLoad() {
        super.viewDidLoad()

        
       
//        
//        //only apply the blur if the user hasn't disabled transparency effects
//        if #available(iOS 8.0, *) {
//            if !UIAccessibilityIsReduceTransparencyEnabled() {
//                //    self.view.backgroundColor = UIColor.clearColor()
//                
//
//                let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
//               
//
//                let blurEffectView = UIVisualEffectView(effect: blurEffect)
//                
//                //always fill the view
//                blurEffectView.frame = self.view.bounds
//                blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
//                
//                //self.view.insertSubview(blurEffectView, atIndex: 0)//if you have more UIViews, use an insertSubview API to place it where needed
//            } 
//            else {
//                self.view.backgroundColor = UIColor.blackColor()
//            }
//        } else {
//            // Fallback on earlier versions
//        }
//        
//        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func continueToMap(sender: UIButton) {
        
        let  storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let  riderMapViewController = storyboard.instantiateViewControllerWithIdentifier("RevealViewController")
        
        
        self.presentViewController(riderMapViewController, animated: false, completion: nil)
        
        
        
    }

}
