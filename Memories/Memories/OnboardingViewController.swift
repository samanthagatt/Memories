//
//  OnboardingViewController.swift
//  Memories
//
//  Created by Samantha Gatt on 8/1/18.
//  Copyright © 2018 Samantha Gatt. All rights reserved.
//

import UIKit

class OnboardingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        localNotificationHelper.getAuthorizationStatus { (status) in
            if status == .authorized {
                self.performSegue(withIdentifier: "PresentNavController", sender: nil)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func getStarted(_ sender: Any) {
        localNotificationHelper.requestAuthorization { (success) in
            if success == true {
                self.localNotificationHelper.scheduleDailyReminderNotification()
            }
            self.performSegue(withIdentifier: "PresentNavController", sender: nil)
        }
    }
    
    // MARK: - Properties
    
    let localNotificationHelper = LocalNotificationHelper()
    
}
