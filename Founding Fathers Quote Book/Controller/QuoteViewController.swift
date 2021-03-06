//
//  QuoteViewController.swift
//  Founding Fathers Quote Book
//
//  Created by Gavin Nitta on 9/19/17.
//  Copyright © 2017 Steve Liddle. All rights reserved.
//

import UIKit
import WebKit

class QuoteViewController: UIViewController {
    
    // MARK: - Constants
    private struct Storyboard {
        static let QuoteOfTheDayTitle = "Quote of the Day"
        static let ShowTopicsSegueIdentifier = "ShowTopics"
        static let TodayTitle = "Today"
        static let TopicsTitle = "Topics"
    }
    
    // Mark: - Outlets
    @IBOutlet weak var toggleButton: UIBarButtonItem!
    @IBOutlet weak var webView: WKWebView!
    
    // Mark: - Properties
    var currentQuoteIndex = 0
    var quotes: [Quote]!
    var topic: String?
    
    // Mark: - View Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    // Mark: - Actions
    @IBAction func showQuoteOfTheDay() {
        topic = nil
        configure()
    }
    
    @IBAction func swipe(_ sender: UISwipeGestureRecognizer) {
        if sender.direction == .left {
            currentQuoteIndex -= 1
            if currentQuoteIndex < 0 {
                currentQuoteIndex = quotes.count - 1
            }
        } else {
            currentQuoteIndex += 1
            if currentQuoteIndex >= quotes.count {
                currentQuoteIndex = 0
            }
        }
        updateUIByToggling()
    }
    
    @IBAction func toggleTopics(_ sender: UIBarButtonItem) {
        if sender.title == Storyboard.TopicsTitle {
            performSegue(withIdentifier: Storyboard.ShowTopicsSegueIdentifier, sender: sender)
        } else {
            showQuoteOfTheDay()
        }
    }
    
    // Mark: - Helpers
    private func chooseQuoteOfTheDay() {
        let formatter = DateFormatter()
        formatter.dateFormat = "DDD"
        if let dayInYear = Int(formatter.string(from: Date())) {
            currentQuoteIndex = dayInYear % QuoteDeck.sharedInstance.quotes.count
        }
    }
    
    private func configure() {
        if let currentTopic = topic {
            quotes = QuoteDeck.sharedInstance.quotesForTag(currentTopic)
            currentQuoteIndex = 0
        } else {
            quotes = QuoteDeck.sharedInstance.quotes
            chooseQuoteOfTheDay()
        }
        updateUI()
    }
    
    private func updateUI() {
        let currentQuote = quotes[currentQuoteIndex]
        if let currentTopic = topic {
            toggleButton.title = Storyboard.TodayTitle
            title = "\(currentTopic.capitalized) (\(currentQuoteIndex + 1) of \(quotes.count))"
        } else {
            toggleButton.title = Storyboard.TopicsTitle
            title = Storyboard.QuoteOfTheDayTitle
        }
        webView.loadHTMLString(currentQuote.html, baseURL: nil)
    }
    
    private func updateUIByToggling() {
        let quote = quotes[currentQuoteIndex]
        if let currentTopic = topic {
            let fadeTextAnimation = CATransition()
            fadeTextAnimation.duration = 0.75
            fadeTextAnimation.type = kCATransitionFade
            navigationController?.navigationBar.layer.add(fadeTextAnimation, forKey: "fadeText")
            navigationItem.title = "\(currentTopic.capitalized) (\(currentQuoteIndex + 1) of \(quotes.count))"
        }
        webView.evaluateJavaScript("toggleQuote('\(quote.text)', '\(quote.speaker)')", completionHandler: nil)
    }
    
    // Mark: - Seques
    @IBAction func exitModalScene(_ segue: UIStoryboardSegue) {
        // In this case, there is nothing to do, but we need a target
    }
    
    @IBAction func showTopicQuotes(_ seque: UIStoryboardSegue) {
        configure()
    }
}
