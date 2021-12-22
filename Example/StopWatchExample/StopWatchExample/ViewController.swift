//
//  ViewController.swift
//  StopWatchExample
//
//  Created by crexista on 2020/09/25.
//  Copyright © 2020 st.crexi. All rights reserved.
//

import UIKit
import UseCaseKit

class ViewController: UIViewController {

    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var startButton: UIButton!
    @IBOutlet private weak var resetButton: UIButton!
    @IBOutlet private weak var stopButton: UIButton!
    
    private var stopWatchUseCase: UseCase<StopWatchCommand>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stopWatchUseCase = .stopWatch()
        stopWatchUseCase?.sink(on: .main) { [weak self] in
                switch $0 {
                case let .counting(num):
                    self?.counterLabel.text = "\(num)"
                    self?.startButton.isHidden = true
                    self?.resetButton.isEnabled = false
                    self?.stopButton.isHidden = false
                case let .pause(num):
                    self?.counterLabel.text = "\(num)"
                    self?.startButton.isHidden = false
                    self?.resetButton.isEnabled = true
                    self?.stopButton.isHidden = true
                case .stopped:
                    self?.counterLabel.text = "0"
                    self?.startButton.isHidden = false
                    self?.resetButton.isEnabled = false
                    self?.stopButton.isHidden = true
            }
        }
    }

    @IBAction func onTapStartButton(_ sender: Any) { stopWatchUseCase?.dispatch(.start) }

    @IBAction func onTapResetButton(_ sender: Any) { stopWatchUseCase?.dispatch(.reset) }

    @IBAction func onTapStopButton(_ sender: Any) { stopWatchUseCase?.dispatch(.stop) }
    
}
