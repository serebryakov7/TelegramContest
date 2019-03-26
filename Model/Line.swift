//
//  Line.swift
//  TelegramChart
//
//  Created by Ivan Serebryakov on 19/03/2019.
//  Copyright © 2019 Ivan Serebryakov. All rights reserved.
//

import Foundation
import UIKit

public enum ColumnType : String {
    case x
    case line
}

public struct Graph {
    let column: Array<CGFloat>
    let color: UIColor
    let name: String
    let type: ColumnType
    var isHidden: Bool
    
    init(column: Array<CGFloat>,
         color: UIColor,
         name: String,
         type: ColumnType,
         isHidden: Bool) {
        self.column = column
        self.color = color
        self.name = name
        self.type = type
        self.isHidden = isHidden
    }
}
