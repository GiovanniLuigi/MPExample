//
//  MPHelper.swift
//  CorMP
//
//  Created by Giovanni Bruno on 07/05/18.
//  Copyright © 2018 Giovanni Bruno. All rights reserved.
//

import Foundation
import MultipeerConnectivity

protocol ReceiverDelegate {
    
    func receive(data: Data, from peer: MCPeerID)
    
    func receive(error: Error)
    
}

class MPHelper: NSObject {
    
    static let shared = MPHelper()
    
    var receiverDelegate: ReceiverDelegate?
    
    var isSingleRoom: Bool = true
    
    var session : MCSession?
    
    var peerId = MCPeerID(displayName: UIDevice.current.name)
    
    private let serviceType = "giovanni123"
    
    private var serviceAdvertiser: MCNearbyServiceAdvertiser!
    
    private var serviceBrowser : MCNearbyServiceBrowser!
    
    override init() {
        super.init()
    }
    
    func prepare(name: String) {
        peerId = MCPeerID(displayName: name)
        serviceAdvertiser = MCNearbyServiceAdvertiser(peer: peerId, discoveryInfo: nil, serviceType: serviceType)
        serviceBrowser = MCNearbyServiceBrowser(peer: peerId, serviceType: serviceType)
        
        self.serviceAdvertiser.delegate = self
        self.serviceBrowser.delegate = self
        
        createSession()
    }
    
    func send(data: Data, dataMode: MCSessionSendDataMode) {
        guard let session = self.session else{return}
        if session.connectedPeers.count > 0 {
            do {
                try session.send(data, toPeers: session.connectedPeers, with: dataMode)
            }
            catch let error {
                receiverDelegate?.receive(error: error)
                print("Error for sending: \(error)")
            }
        }
    }
    
    func startAdvertesing() {
        self.serviceAdvertiser.startAdvertisingPeer()
    }
    
    func stopAdvertising() {
        self.serviceAdvertiser.stopAdvertisingPeer()
    }
    
    func startBrowsing(){
        self.serviceBrowser.startBrowsingForPeers()
    }
    
    func stopBrowsing(){
        self.serviceBrowser.stopBrowsingForPeers()
    }
    
    func joinSession(session id: MCPeerID){
        guard let session = self.session else {
            print("É preciso criar uma sessão antes de usar este método, bobinho...")
            return
        }
        self.serviceBrowser.invitePeer(id, to: session, withContext: nil, timeout: 180)
    }
    
    func leaveSession() {
        session?.disconnect()
    }
    
    private func createSession() {
        session = MCSession(peer: peerId, securityIdentity: nil, encryptionPreference: .none)
        session?.delegate = self
    }
    
    deinit {
        self.serviceAdvertiser.stopAdvertisingPeer()
        self.serviceBrowser.stopBrowsingForPeers()
    }
    
}

extension MPHelper: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        print("didNotStartAdvertisingPeer: \(error)")
        receiverDelegate?.receive(error: error)
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        
        print("didReceiveInvitationFromPeer \(peerID)")
        invitationHandler(true, session)
    }
}

extension MPHelper: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        print("didNotStartBrowsingForPeers: \(error)")
        receiverDelegate?.receive(error: error)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        print("foundPeer: \(peerID)")
        guard let session = self.session else {return}
        if isSingleRoom && session.connectedPeers.count < 6 {
            joinSession(session: peerID)
        }
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("lostPeer: \(peerID)")
    }
}

extension MPHelper: MCSessionDelegate {
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        print("peer \(peerID) didChangeState: \(state.rawValue)")
        if state == .connected {
        }else if state == .notConnected {
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        receiverDelegate?.receive(data: data, from: peerID)
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        guard let e = error else {return}
        receiverDelegate?.receive(error: e)
    }
    
}

