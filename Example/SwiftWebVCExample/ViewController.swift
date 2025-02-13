//
//  ViewController.swift
//  SwiftWebVCExample
//
//  Created by Myles Ringle on 20/12/2016.
//  Copyright © 2016 Myles Ringle. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: Push
    @IBAction func push() {
        let webVC = SwiftWebVC(urlString: "https://www.google.com")
        webVC.delegate = self
        self.navigationController?.pushViewController(webVC, animated: true)
        self.navigationController?.hidesBarsOnSwipe = true
    }
    
    // MARK: Modal
    @IBAction func presentModalWithDefaultTheme() {
        let webVC = SwiftModalWebVC(urlString: "www.google.com")
        webVC.hidesBarsOnSwipe = true
        self.present(webVC, animated: true, completion: nil)
    }
    
    @IBAction func presentModalWithLightBlackTheme() {
        let webVC = SwiftModalWebVC(urlString: "https://www.google.com", theme: .lightBlack, dismissButtonStyle: .cross)
        webVC.hidesBarsOnSwipe = true
        self.present(webVC, animated: true, completion: nil)
    }
    
    @IBAction func presentModalWithDarkTheme() {
        let webVC = SwiftModalWebVC(urlString: "https://www.google.com", theme: .dark, dismissButtonStyle: .arrow)
        webVC.hidesBarsOnSwipe = true
        self.present(webVC, animated: true, completion: nil)
    }

}

extension ViewController: SwiftWebVCDelegate {
    
    func didStartLoading() {
        print("Started loading.")
    }
    
    func didFinishLoading(success: Bool) {
        print("Finished loading. Success: \(success).")
    }
    
    func didWideActionButtonTapped() {
        print("Wide Action Button tapped.")
    }
}
