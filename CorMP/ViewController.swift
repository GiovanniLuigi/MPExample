//
//  ViewController.swift
//  CorMP
//
//  Created by Giovanni Bruno on 07/05/18.
//  Copyright © 2018 Giovanni Bruno. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class ViewController: UIViewController, ReceiverDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        MPHelper.shared.receiverDelegate = self
        MPHelper.shared.startBrowsing()
        MPHelper.shared.startAdvertesing()
    }
    
    func receive(data: Data, from peer: MCPeerID) {
        let color = String.init(data: data, encoding: .utf8)
        if color == "red" {
            self.view.backgroundColor = .red
        } else if color == "green" {
            self.view.backgroundColor = .green
        }
    }
    
    func receive(error: Error) {
        
    }
    
    @IBAction func tapRed(_ sender: Any) {
        self.view.backgroundColor = .red
        MPHelper.shared.send(data: "red".data(using: .utf8, allowLossyConversion: false)!, dataMode: .reliable)
    }
    
    @IBAction func tapGreen(_ sender: Any) {
        self.view.backgroundColor = .green
        MPHelper.shared.send(data: "green".data(using: .utf8, allowLossyConversion: false)!, dataMode: .reliable)
    }
    
}

