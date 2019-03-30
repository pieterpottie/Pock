//
//  SWifiItem.swift
//  Pock
//
//  Created by Pierluigi Galdi on 23/02/2019.
//  Copyright © 2019 Pierluigi Galdi. All rights reserved.
//

import Foundation
import Defaults
import CoreWLAN

class SWifiItem: StatusItem {
    
    /// Core
    private let wifiClient: CWWiFiClient = CWWiFiClient.shared()
    
    /// UI
    private let iconView: NSImageView = NSImageView(frame: NSRect(x: 0, y: 0, width: 26, height: 26))
    
    init() {
        self.wifiClient.delegate = self
        try? wifiClient.startMonitoringEvent(with: .linkDidChange)
        try? wifiClient.startMonitoringEvent(with: .ssidDidChange)
        try? wifiClient.startMonitoringEvent(with: .powerDidChange)
        try? wifiClient.startMonitoringEvent(with: .linkQualityDidChange)
        reload()
    }
    
    var enabled: Bool{ return defaults[.shouldShowWifiItem] }
    
    var title: String  { return "wifi" }
    
    var view: NSView { return iconView }
    
    func action() {
        print("[Pock]: WiFi Status icon tapped!")
    }
    
    func reload() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            let rssi: Int   = self?.wifiClient.interface()?.rssiValue() ?? 0
            let percentage  = rssi == 0 ? 0 : min(max(2 * (rssi + 100), 0), 100)
            let code: Int   = Int(percentage / 10)
            let icon: NSImage.Name!
            switch (code) {
            case 0:
                icon = NSImage.Name(rawValue: "wifiOff")
            default:
                let c = code - 1
                icon = NSImage.Name(rawValue: "wifi\(c > 4 ? 4 : c)")
            }
            DispatchQueue.main.async { [weak self] in
                self?.iconView.image = NSImage(named: icon)
            }
        }
    }
    
}

extension SWifiItem: CWEventDelegate {
    func linkDidChangeForWiFiInterface(withName interfaceName: String) {
        self.reload()
    }
    func ssidDidChangeForWiFiInterface(withName interfaceName: String) {
        self.reload()
    }
    func powerStateDidChangeForWiFiInterface(withName interfaceName: String) {
        self.reload()
    }
    func linkQualityDidChangeForWiFiInterface(withName interfaceName: String, rssi: Int, transmitRate: Double) {
        self.reload()
    }
}
