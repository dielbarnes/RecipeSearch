//
//  WebViewController.swift
//  RecipeSearch
//
//  Created by Diel Barnes on 18/05/2017.
//  Copyright © 2017 Hacarus. All rights reserved.
//

import UIKit

class WebViewController: UIViewController, UIWebViewDelegate {
    
    var urlString: String?
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if urlString != nil, let url = URL(string: urlString!) {
            
            activityIndicator.startAnimating()
            
            let request = URLRequest(url: url)
            webView.loadRequest(request)
        }
    }
    
    // MARK: - Web View Methods
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        activityIndicator.stopAnimating()
    }
    
    // MARK: - Button Methods
    
    @IBAction func closeButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
}
