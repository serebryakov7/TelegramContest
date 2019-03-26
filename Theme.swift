//
//  Theme.swift
//  TelegramChart
//
//  Created by Ivan Serebryakov on 21/03/2019.
//  Copyright © 2019 Ivan Serebryakov. All rights reserved.
//

import UIKit

final class Theme {
    
    static let shared = Theme()
    private init() {}
    
    private let themeModeKey = "Chart_Theme_Key"
    
    enum ThemeMode: Int {
        case day = 0
        case night = 1
    }
    
    var mode: ThemeMode = (ThemeMode(rawValue: (UserDefaults.standard.value(forKey: "Chart_Theme_Key") as? Int) ?? 0) ?? .day)
    {
        didSet {
            UserDefaults.standard.setValue(mode.rawValue, forKey: themeModeKey)
            NotificationCenter.default.post(name: .didSwitchTheme, object: nil)
        }
    }
    
    func switchTheme() {
        switch mode {
        case .day: mode = .night
        case .night: mode = .day
        }
    }
}

extension Theme {
    var barStyle: UIStatusBarStyle {
        switch mode {
        case .day: return .default
        case .night: return .lightContent
        }
    }
    
    var mainColor: UIColor {
        switch mode {
        case .day: return UIColor(netHex: 0xFEFEFE)
        case .night: return UIColor(netHex: 0x222F3F)
        }
    }
    
    var additionalColor: UIColor {
        switch mode {
        case .day: return UIColor(netHex: 0xEFEFF4)
        case .night: return UIColor(netHex: 0x18222D)
        }
    }
    
    var mainTextColor: UIColor {
        switch mode {
        case .day: return UIColor(netHex: 0x000000)
        case .night: return UIColor(netHex: 0xFFFFFF)
        }
    }
    
    var additionalTextColor: UIColor {
        switch mode {
        case .day: return UIColor(netHex: 0x68686D)
        case .night: return UIColor(netHex: 0x5B6B80)
        }
    }
    
    var controlColor: UIColor {
        switch mode {
        case .day: return UIColor(netHex: 0xCAD4DE)
        case .night: return UIColor(netHex: 0x354659)
        }
    }
    
    var controllArrowColor: UIColor {
        switch mode {
        case .day: return UIColor(netHex: 0x6F6E6E)
        case .night: return UIColor(netHex: 0xFFFFFF)
        }
    }
    
    var buttonTextColor: UIColor {
        return UIColor(netHex: 0x007AFF)
    }
    
    var switchButtonText: String {
        switch mode {
        case .day: return "Switch to Night Mode"
        case .night: return "Switch to Day Mode"
        }
    }
}

extension Notification.Name {
    static let didSwitchTheme = Notification.Name("didChangeTheme")
}
