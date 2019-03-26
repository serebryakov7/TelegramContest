//
//  ViewController.swift
//  TelegramChart
//
//  Created by Ivan Serebryakov on 21/03/2019.
//  Copyright © 2019 Ivan Serebryakov. All rights reserved.
//

import Foundation
import UIKit

fileprivate struct ViewControllerConstants {
    static let title = "Statistics"
}

final class ViewController: UIViewController {
    
    private lazy var tableView: ChartsTableView = {
        var tableView = ChartsTableView(frame: .zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private func updateColors() {
        self.tableView.reloadData()
        UIView.animate(withDuration: 0.2) { [unowned self] in
            self.view.backgroundColor = Theme.shared.additionalColor
            self.navigationController?.navigationBar.barTintColor = Theme.shared.mainColor
            self.navigationController?.navigationBar.titleTextAttributes =
                [NSAttributedString.Key.foregroundColor: Theme.shared.mainTextColor]
            self.tableView.backgroundColor = Theme.shared.additionalColor
            UIApplication.shared.statusBarStyle = Theme.shared.barStyle
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do { tableView.charts = try parseJson() } catch { fatalError() }
        
        navigationItem.title = ViewControllerConstants.title
        navigationController?.navigationBar.isTranslucent = false
        
        updateColors()
        
        view.addSubview(tableView)
        
        setupConstraints()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onDidReceiveData(_:)),
                                               name: .didSwitchTheme,
                                               object: nil)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self,
                                                  name: .didSwitchTheme,
                                                  object: nil)
    }
    
    @objc private func onDidReceiveData(_ notification: Notification) {
        updateColors()
    }
    
    private func parseJson() throws -> [Chart] {
        guard let url = Bundle.main.url(forResource: "dataset", withExtension: "json") else { fatalError() }
        
        let jsonData = try Data(contentsOf: url)
        let chart = try JSONDecoder().decode([Chart].self, from: jsonData)
        return chart
    }
}

