//
//  TopicsViewController.swift
//  Founding Fathers Quote Book
//
//  Created by Gavin Nitta on 9/19/17.
//  Copyright © 2017 Steve Liddle. All rights reserved.
//

import UIKit

class TopicsViewController : UITableViewController {
    
    // Mark: - Constants
    private struct Storyboard {
        static let ShowQuoteSequeIdentifier = "ShowQuote"
        static let TopicCellIdentifier = "TopicCell"
    }
    
    // Mark: - Properties
    var selectedTopic: String?
    
    // Mark: - View Controller Lifecycle
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? QuoteViewController {
            destinationVC.topic = selectedTopic
        }
    }
    
    // Mark: - Table View Data Source
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.TopicCellIdentifier, for: indexPath)
        cell.textLabel?.text = QuoteDeck.sharedInstance.tagSet[indexPath.row].capitalized
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return QuoteDeck.sharedInstance.tagSet.count
    }
    
    // Mark: - Table View Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedTopic = QuoteDeck.sharedInstance.tagSet[indexPath.row]
        performSegue(withIdentifier: Storyboard.ShowQuoteSequeIdentifier, sender: self)
    }
}
