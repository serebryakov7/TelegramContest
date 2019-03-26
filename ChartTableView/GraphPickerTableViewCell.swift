//
//  LineTableViewCell.swift
//  TelegramChart
//
//  Created by Ivan Serebryakov on 21/03/2019.
//  Copyright © 2019 Ivan Serebryakov. All rights reserved.
//

import UIKit

final class GraphPickerTableViewCell : UITableViewCell {
    override var isSelected: Bool {
        didSet {
            accessoryType = isSelected ? .checkmark : .none
        }
    }
    
    lazy var rectView: UIView = {
        var view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 5
        return view
    }()
    
    lazy var bottomView: UIView = {
        var view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var titleLabel: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(rectView)
        addSubview(bottomView)
        addSubview(titleLabel)
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            rectView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            rectView.centerYAnchor.constraint(equalTo: centerYAnchor),
            rectView.heightAnchor.constraint(equalToConstant: 15),
            rectView.widthAnchor.constraint(equalToConstant: 15)
            ])
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: rectView.trailingAnchor, constant: 15),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            ])
        NSLayoutConstraint.activate([
            bottomView.heightAnchor.constraint(equalToConstant: 1),
            bottomView.bottomAnchor.constraint(equalTo: bottomAnchor),
            bottomView.leadingAnchor.constraint(equalTo: rectView.trailingAnchor, constant: 15),
            bottomView.trailingAnchor.constraint(equalTo: trailingAnchor)
            ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
