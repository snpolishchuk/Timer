//
//  TimerViewController.swift
//  Timer
//
//  Created by Oleksandr Polishchuk on 18.08.2020.
//  Copyright © 2020 Oleksandr Polishchuk. All rights reserved.
//

import UIKit

class TimerViewController: UIViewController {
    // MARK: Outlets
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var stopButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var startButtonWidthConstraint: NSLayoutConstraint!
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        configureUIAfterAutolayout()
    }
    
    // MARK: Button actions
    @IBAction func stopButtonPressed(_ sender: Any) {
    }
    
    @IBAction func startButtonPressed(_ sender: Any) {
        
    }
    
    // MARK: UI Configuration
    private func configureUI() {
        // Set large font size to scale to the proper one after viewDidLayoutSubviews
        timeLabel.font = UIFont.systemFont(ofSize: 100)
        timeLabel.numberOfLines = 1
        
        // Adjust button sizes to fit text
        let startButtonWidth = startButton.intrinsicContentSize.width
        let stopButtonWidth = stopButton.intrinsicContentSize.width
        let maxWidth = startButtonWidth > stopButtonWidth ? startButtonWidth : stopButtonWidth
        startButtonWidthConstraint.constant = maxWidth
        stopButtonWidthConstraint.constant = maxWidth
    }
    
    private func configureUIAfterAutolayout() {
        // Actions needed to have time label size scale to the whole screen width on all devices
        timeLabel.adjustsFontSizeToFitWidth = true
        timeLabel.minimumScaleFactor = 0.1
        
        // Make buttons round after Autolayout settings (we have aspect ratio 1:1 for buttons)
        startButton.layer.cornerRadius = startButton.frame.size.height / 2
        stopButton.layer.cornerRadius = startButton.frame.size.height / 2
    }
}

