//
//  OnboardingPageViewController.swift
//  Photopon
//
//  Created by Damien Rottemberg on 2/6/18.
//  Copyright © 2018 Photopon. All rights reserved.
//

import UIKit
import CoreLocation

class OnboardingPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, LocationServicesViewControllerDelegate, EnjoyPhotoponDelegate, PushNotificationsDelegate, NumberVerificationDelegate {
  
   
    

    var pages = [UIViewController]()
    var didViewAlreadyAppear = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.delegate = self
        self.dataSource = self

        let page1: UIViewController! = storyboard?.instantiateViewController(withIdentifier: "WelcomeStaticViewController")
        let page2: LocationServicesViewController! = storyboard?.instantiateViewController(withIdentifier: "LocationServicesViewController") as! LocationServicesViewController
        let page3: PushNotificationsViewController! = storyboard?.instantiateViewController(withIdentifier: "PushNotificationsViewController") as! PushNotificationsViewController
        let page4: EnjoyPhotoponViewController! = storyboard?.instantiateViewController(withIdentifier: "EnjoyPhotoponViewController") as! EnjoyPhotoponViewController
        
        page2.delegate = self
        page3.delegate = self
        page4.delegate = self
        
        pages.append(page1)
        pages.append(page2)
        pages.append(page3)
        pages.append(page4)

        setViewControllers([page1], direction: UIPageViewControllerNavigationDirection.forward, animated: false, completion: nil)
        
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        if(!didViewAlreadyAppear){
            didViewAlreadyAppear = true
            
            if(UIApplication.shared.isRegisteredForRemoteNotifications && PPTools.isLocationEnabled() == 2){
                
                setViewControllers([pages[3]], direction: UIPageViewControllerNavigationDirection.forward, animated: false, completion: nil)
                
                
            }
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let currentIndex = pages.index(of:viewController)!
        
        if(currentIndex - 1 < 0){ return nil
        }
        
        let previousIndex = abs((currentIndex - 1))
        return pages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let currentIndex = pages.index(of:viewController)!
        
        if(currentIndex + 1 >= pages.count){ return nil }
        let nextIndex = abs((currentIndex + 1))
        return pages[nextIndex]
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return pages.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return pages.index(of:pageViewController.viewControllers!.first!)!
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func didAllowLocationServices() {
        setViewControllers([pages[2]], direction: UIPageViewControllerNavigationDirection.forward, animated: false, completion: nil)
        
    }
    
    func userDidAllowPushNotifications() {
        setViewControllers([pages[3]], direction: UIPageViewControllerNavigationDirection.forward, animated: false, completion: nil)
    }
    
    
    func userShouldRegister() {
        
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SBNumberVerification") as! NumberVerificationViewController
        UIApplication.shared.setStatusBarStyle(.default, animated: true)
        vc.delegate = self
        self.navigationController?.present(vc, animated: true, completion: nil)
    }
    
    func userShouldSkip() {
        
        
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainCtrl")
        vc.modalTransitionStyle = .flipHorizontal
        UIApplication.shared.setStatusBarStyle(.lightContent, animated: true)
        self.navigationController?.present(vc, animated: true, completion: nil)
        
        
    }
    
    func userVerifiedPhoneNumber() {
        
        
        let currentInstallation = PFInstallation.current()
        let currentUser = PFUser.current()
        
        let channel = "User_"+currentUser!.objectId!
        currentInstallation.addUniqueObject(channel, forKey: "channel")
        currentInstallation.saveInBackground()
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainCtrl")
        vc.modalTransitionStyle = .flipHorizontal
        UIApplication.shared.setStatusBarStyle(.lightContent, animated: true)
        self.navigationController?.present(vc, animated: true, completion: nil)
        
        

    }
    
    func userFailedToVerify() {
        
    }
    
    func userSkippedVerification() {
        self.userShouldSkip()
    }
    

}
