//
//  SearchViewController.swift
//  RecipeSearch
//
//  Created by Diel Barnes on 18/05/2017.
//  Copyright © 2017 Diel Barnes. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UIScrollViewDelegate {

    var searchResults: [Recipe] = []
    var hasMoreResults: Bool = false
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var recipeTableView: UITableView!
    @IBOutlet weak var noResultsLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        recipeTableView.tableFooterView = UIView(frame: .zero)
    }
    
    // MARK: - Web Requests
    
    func searchRecipe(_ name: String, newSearch: Bool) {
        
        if newSearch {
            searchResults.removeAll()
            recipeTableView.reloadData()
        }
        
        //Create URL
        
        let parameters: [URLQueryItem] = [URLQueryItem(name: "q", value: name),
                                          URLQueryItem(name: "app_id", value: "334597fd"),
                                          URLQueryItem(name: "app_key", value: "1885eb04264cd11a86208ee4c489574e"),
                                          URLQueryItem(name: "from", value: "\(searchResults.count)"),
                                          URLQueryItem(name: "to", value: "\(searchResults.count + 19)")]
        
        var urlComponents = URLComponents(string: "https://api.edamam.com/search")
        urlComponents?.queryItems = parameters
        
        if let url = urlComponents?.url {
            
            //Manage UI
            
            noResultsLabel.isHidden = true
            activityIndicator.startAnimating()
            
            //Send Request
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            
            let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
                
                if error != nil { //Fail
                    
                    DispatchQueue.main.async {
                        
                        self.activityIndicator.stopAnimating()
                        
                        let alertController = UIAlertController(title: "Recipe Search Failed", message: error!.localizedDescription, preferredStyle: .alert)
                        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alertController.addAction(action)
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
                else { //Success
                    
                    if name == self.searchBar.text, data != nil, let json = try? JSONSerialization.jsonObject(with: data!, options: []), let dictionary = json as? [String: Any] {
                        
                        if let more = dictionary["more"] as? Bool {
                            self.hasMoreResults = more
                        }
                        
                        if let hits = dictionary["hits"] as? [[String: Any]] {
                            
                            for hit in hits {
                                
                                if let recipe = hit["recipe"] as? [String: Any], let name = recipe["label"] as? String, let urlString = recipe["url"] as? String {
                                    
                                    self.searchResults.append(Recipe(name: name, urlString: urlString))
                                }
                            }
                            
                            //Update UI
                            
                            DispatchQueue.main.async {
                                
                                self.activityIndicator.stopAnimating()
                                
                                self.recipeTableView.reloadData()
                                
                                if self.searchResults.count == 0 {
                                    self.noResultsLabel.isHidden = false
                                }
                                else {
                                    self.noResultsLabel.isHidden = true
                                }
                            }
                        }
                    }
                }
            })
            task.resume()
        }
    }
    
    // MARK: Search Bar Methods
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.isEmpty {
            searchResults.removeAll()
            recipeTableView.reloadData()
        }
        else {
            searchRecipe(searchText, newSearch: true)
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        if let searchText = searchBar.text {
            searchRecipe(searchText, newSearch: true)
        }
        
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    // MARK: Table View Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeCell", for: indexPath) as! RecipeCell
        
        let recipe = searchResults[indexPath.row]
        
        cell.nameLabel.text = recipe.name
        cell.urlLabel.text = recipe.urlString
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let recipe = searchResults[indexPath.row]
        
        let viewController = storyboard!.instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
        viewController.urlString = recipe.urlString
        show(viewController, sender: self)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if let searchText = searchBar.text, hasMoreResults, indexPath.row == searchResults.count - 1 {
            searchRecipe(searchText, newSearch: false)
        }
    }
    
    // MARK: - Scroll View Methods
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
    }
}
