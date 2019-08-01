//
//  SwiftWebVC.swift
//
//  Created by Myles Ringle on 24/06/2015.
//  Transcribed from code used in SVWebViewController.
//  Copyright (c) 2015 Myles Ringle & Sam Vermette. All rights reserved.
//

import WebKit

public protocol SwiftWebVCDelegate: class {
    func didStartLoading()
    func didFinishLoading(success: Bool)
    func didWideActionButtonTapped()
}

public class SwiftWebVC: UIViewController {
    
    public weak var delegate: SwiftWebVCDelegate?
    public var storedStatusColor: UIBarStyle?
    public var buttonColor: UIColor? = nil
    public var titleColor: UIColor? = nil
    public var closing: Bool! = false
    
    lazy var backBarButtonItem: UIBarButtonItem =  {
        var tempBackBarButtonItem = UIBarButtonItem(image: SwiftWebVC.bundledImage(named: "SwiftWebVCBack"),
                                                    style: UIBarButtonItem.Style.plain,
                                                    target: self,
                                                    action: #selector(SwiftWebVC.goBackTapped(_:)))
        tempBackBarButtonItem.width = 18.0
        tempBackBarButtonItem.tintColor = self.buttonColor
        return tempBackBarButtonItem
    }()
    
    lazy var forwardBarButtonItem: UIBarButtonItem =  {
        var tempForwardBarButtonItem = UIBarButtonItem(image: SwiftWebVC.bundledImage(named: "SwiftWebVCNext"),
                                                       style: UIBarButtonItem.Style.plain,
                                                       target: self,
                                                       action: #selector(SwiftWebVC.goForwardTapped(_:)))
        tempForwardBarButtonItem.width = 18.0
        tempForwardBarButtonItem.tintColor = self.buttonColor
        return tempForwardBarButtonItem
    }()
    
    lazy var refreshBarButtonItem: UIBarButtonItem = {
        var tempRefreshBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.refresh,
                                                       target: self,
                                                       action: #selector(SwiftWebVC.reloadTapped(_:)))
        tempRefreshBarButtonItem.tintColor = self.buttonColor
        return tempRefreshBarButtonItem
    }()
    
    lazy var actionBarButtonItem: UIBarButtonItem = {
        var tempActionBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.action,
                                                      target: self,
                                                      action: #selector(SwiftWebVC.actionButtonTapped(_:)))
        tempActionBarButtonItem.tintColor = self.buttonColor
        return tempActionBarButtonItem
    }()
    
    lazy var wideActionBarButtonItem: UIBarButtonItem = {
        var tempWideActionBar = UIBarButtonItem(customView: wideActionButton)
        return tempWideActionBar
    }()
    
    public lazy var wideActionButton: UIButton = {
        // Jie - Example to use attributed string
//        let fullString = NSMutableAttributedString(string: "VIEW CASHBACK INFO      ", attributes: [.font: UIFont.systemFont(ofSize: 13), NSAttributedString.Key.foregroundColor: UIColor.white])
//        let imageAttachment = NSTextAttachment()
//        imageAttachment.image = UIImage(named: "SwiftWebVCViewMoreCollapsed")
//        let imageString = NSMutableAttributedString(attachment: imageAttachment)
//        imageString.addAttribute(NSAttributedString.Key.baselineOffset, value: 2, range: NSRange(location: 0, length: imageString.length))
//        fullString.append(imageString)
        
        let tempButton = UIButton()
        tempButton.frame = CGRect(x: 0, y: 0, width: 206, height: 30)
        tempButton.backgroundColor = UIColor(hexString: "#d71377")
        tempButton.layer.cornerRadius = 17
        tempButton.layer.masksToBounds = true
//        tempButton.setAttributedTitle(fullString, for: .normal)
        tempButton.addTarget(self, action: #selector(wideActionButtonTapped(_:)), for: .touchUpInside)
        
        return tempButton
    }()
    
    lazy var webView: WKWebView = {
        var tempWebView = WKWebView(frame: UIScreen.main.bounds)
        tempWebView.uiDelegate = self
        tempWebView.navigationDelegate = self
        tempWebView.scrollView.delegate = self
        return tempWebView;
    }()
    
    var request: URLRequest!
    
    var navBarTitle: UILabel!
    
    public var sharingEnabled = true
    
    ////////////////////////////////////////////////
    
    deinit {
        webView.stopLoading()
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        webView.uiDelegate = nil;
        webView.navigationDelegate = nil;
    }
    
    public convenience init(urlString: String, sharingEnabled: Bool = true) {
        var urlString = urlString
        if !urlString.hasPrefix("https://") && !urlString.hasPrefix("http://") {
            urlString = "https://"+urlString
        }
        self.init(pageURL: URL(string: urlString)!, sharingEnabled: sharingEnabled)
    }
    
    public convenience init(pageURL: URL, sharingEnabled: Bool = true) {
        self.init(aRequest: URLRequest(url: pageURL), sharingEnabled: sharingEnabled)
    }
    
    public convenience init(aRequest: URLRequest, sharingEnabled: Bool = true) {
        self.init()
        self.sharingEnabled = sharingEnabled
        self.request = aRequest
    }
    
    func loadRequest(_ request: URLRequest) {
        webView.load(request)
    }
    
    ////////////////////////////////////////////////
    // View Lifecycle
    
    public override var prefersStatusBarHidden: Bool {
        return self.navigationController?.isNavigationBarHidden ?? false
    }
    
    override public func loadView() {
        view = webView
        loadRequest(request)
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        assert(self.navigationController != nil, "SVWebViewController needs to be contained in a UINavigationController. If you are presenting SVWebViewController modally, use SVModalWebViewController instead.")
        
        updateToolbarItems()
        navBarTitle = UILabel()
        navBarTitle.backgroundColor = UIColor.clear
        if presentingViewController == nil {
            if let titleAttributes = navigationController!.navigationBar.titleTextAttributes {
                navBarTitle.textColor = titleAttributes[.foregroundColor] as? UIColor
            }
        }
        else {
            navBarTitle.textColor = self.titleColor
        }
        navBarTitle.shadowOffset = CGSize(width: 0, height: 1);
        navBarTitle.font = UIFont(name: "HelveticaNeue-Medium", size: 17.0)
        navBarTitle.textAlignment = .center
        navBarTitle.text = "Loading"
        navigationItem.titleView = navBarTitle;
        
        super.viewWillAppear(true)
        
        if (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone) {
            self.navigationController?.setToolbarHidden(false, animated: false)
        }
        else if (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad) {
            self.navigationController?.setToolbarHidden(true, animated: true)
        }
    }
    
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        if (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone) {
            self.navigationController?.setToolbarHidden(true, animated: true)
        }
    }
    
    override public func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    ////////////////////////////////////////////////
    // Toolbar
    
    func updateToolbarItems() {
        backBarButtonItem.isEnabled = webView.canGoBack
        forwardBarButtonItem.isEnabled = webView.canGoForward
        refreshBarButtonItem.isEnabled = !webView.isLoading
        
        let fixedSpace: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.fixedSpace, target: nil, action: nil)
        let flexibleSpace: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
        if (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad) {
            fixedSpace.width = 35.0
            
            let items: NSArray = sharingEnabled ? [fixedSpace, refreshBarButtonItem, fixedSpace, backBarButtonItem, fixedSpace, forwardBarButtonItem, fixedSpace, actionBarButtonItem, fixedSpace, wideActionBarButtonItem] : [fixedSpace, refreshBarButtonItem, fixedSpace, backBarButtonItem, fixedSpace, forwardBarButtonItem, fixedSpace, wideActionBarButtonItem]
            
            navigationItem.rightBarButtonItems = items.reverseObjectEnumerator().allObjects as? [UIBarButtonItem]
        }
        else {
            let fixedSpace3: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.fixedSpace, target: nil, action: nil)
            fixedSpace3.width = 40
            
            let items: NSArray = sharingEnabled ? [fixedSpace, backBarButtonItem, fixedSpace3, forwardBarButtonItem, fixedSpace, actionBarButtonItem, fixedSpace, wideActionBarButtonItem, fixedSpace] : [fixedSpace, backBarButtonItem, fixedSpace3, forwardBarButtonItem, flexibleSpace, wideActionBarButtonItem, fixedSpace]
            
            if let navigationController = navigationController, !closing {
                if presentingViewController == nil {
                    navigationController.toolbar.barTintColor = navigationController.navigationBar.barTintColor
                }
                else {
                    navigationController.toolbar.barStyle = navigationController.navigationBar.barStyle
                }
                navigationController.toolbar.tintColor = navigationController.navigationBar.tintColor
                
                toolbarItems = items as? [UIBarButtonItem]
                navigationItem.rightBarButtonItem = refreshBarButtonItem
            }
        }
    }
    
    
    ////////////////////////////////////////////////
    // Target Actions
    
    @objc func goBackTapped(_ sender: UIBarButtonItem) {
        webView.goBack()
    }
    
    @objc func goForwardTapped(_ sender: UIBarButtonItem) {
        webView.goForward()
    }
    
    @objc func reloadTapped(_ sender: UIBarButtonItem) {
        webView.reload()
    }
    
    @objc func actionButtonTapped(_ sender: AnyObject) {
        
        if let url: URL = ((webView.url != nil) ? webView.url : request.url) {
            let activities: NSArray = [SwiftWebVCActivitySafari(), SwiftWebVCActivityChrome()]
            
            if url.absoluteString.hasPrefix("file:///") {
                let dc: UIDocumentInteractionController = UIDocumentInteractionController(url: url)
                dc.presentOptionsMenu(from: view.bounds, in: view, animated: true)
            }
            else {
                let activityController: UIActivityViewController = UIActivityViewController(activityItems: [url], applicationActivities: activities as? [UIActivity])
                
                if floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1 && UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad {
                    let ctrl: UIPopoverPresentationController = activityController.popoverPresentationController!
                    ctrl.sourceView = view
                    ctrl.barButtonItem = sender as? UIBarButtonItem
                }
                
                present(activityController, animated: true, completion: nil)
            }
        }
    }
    
    @objc func wideActionButtonTapped(_ sender: AnyObject) {
        delegate?.didWideActionButtonTapped()
    }
    
    ////////////////////////////////////////////////
    
    @objc open func doneButtonTapped() {
        closing = true
        UINavigationBar.appearance().barStyle = storedStatusColor!
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Class Methods
    
    /// Helper function to get image within SwiftWebVCResources bundle
    ///
    /// - parameter named: The name of the image in the SwiftWebVCResources bundle
    open class func bundledImage(named: String) -> UIImage? {
        let image = UIImage(named: named)
        if image == nil {
            return UIImage(named: named, in: Bundle(for: SwiftWebVC.classForCoder()), compatibleWith: nil)
        } // Replace MyBasePodClass with yours
        return image
    }
    
}

extension SwiftWebVC: WKUIDelegate {
    
    // Add any desired WKUIDelegate methods here: https://developer.apple.com/reference/webkit/wkuidelegate
    
}

extension SwiftWebVC: WKNavigationDelegate {
    
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        self.delegate?.didStartLoading()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        updateToolbarItems()
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.delegate?.didFinishLoading(success: true)
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
        webView.evaluateJavaScript("document.title", completionHandler: { [unowned self] (response, error) in
            self.navBarTitle.text = self.request.url?.host
            self.navBarTitle.sizeToFit()
            self.updateToolbarItems()
        })
        
    }
    
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.delegate?.didFinishLoading(success: false)
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        updateToolbarItems()
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        let url = navigationAction.request.url
        
        let hostAddress = navigationAction.request.url?.host
        
        if (navigationAction.targetFrame == nil) {
            if UIApplication.shared.canOpenURL(url!) {
                UIApplication.shared.open(url!, options: [:], completionHandler: nil)
            }
        }
        
        // To connnect app store
        if hostAddress == "itunes.apple.com" {
            if UIApplication.shared.canOpenURL(navigationAction.request.url!) {
                UIApplication.shared.open(navigationAction.request.url!, options: [:], completionHandler: nil)
                decisionHandler(.cancel)
                return
            }
        }
        
        let url_elements = url!.absoluteString.components(separatedBy: ":")
        
        switch url_elements[0] {
        case "tel":
            openCustomApp(urlScheme: "telprompt://", additional_info: url_elements[1])
            decisionHandler(.cancel)
            
        case "sms":
            openCustomApp(urlScheme: "sms://", additional_info: url_elements[1])
            decisionHandler(.cancel)
            
        case "mailto":
            openCustomApp(urlScheme: "mailto://", additional_info: url_elements[1])
            decisionHandler(.cancel)
            
        default:
            //print("Default")
            break
        }
        
        decisionHandler(.allow)
        
    }
    
    func openCustomApp(urlScheme: String, additional_info:String){
        
        if let requestUrl: URL = URL(string:"\(urlScheme)"+"\(additional_info)") {
            let application:UIApplication = UIApplication.shared
            if application.canOpenURL(requestUrl) {
                application.open(requestUrl, options: [:], completionHandler: nil)
            }
        }
    }
}

extension SwiftWebVC: UIScrollViewDelegate {
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
}

// MARK: Extension for built-in UIColor
extension UIColor {
    
    /// Creates an UIColor from HEX String in "#363636" format
    ///
    /// - parameter hexString: HEX String in "#363636" format
    /// - returns: UIColor from HexString
    convenience init(hexString: String) {
        let hexString: String = (hexString as NSString).trimmingCharacters(in: .whitespacesAndNewlines)
        let scanner           = Scanner(string: hexString as String)
        
        if hexString.hasPrefix("#") {
            scanner.scanLocation = 1
        }
        
        var color: UInt32 = 0
        scanner.scanHexInt32(&color)
        
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: 1)
    }
    
}
