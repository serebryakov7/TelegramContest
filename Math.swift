//
//  Math.swift
//  TelegramChart
//
//  Created by Ivan Serebryakov on 26/03/2019.
//  Copyright © 2019 Ivan Serebryakov. All rights reserved.
//

import Foundation
import CoreGraphics

// MARK: - Scale

func horizontalScale (from: CGFloat, to: CGFloat) -> CGFloat {
    return (1 / (to - from))
}

func verticleScale (from: CGFloat, to: CGFloat) -> CGFloat {
    return CGFloat(to / from).rounded(toPlaces: 6)
}

// MARK: - Y-Asix

func totalMaxY (for graphs: Array<Graph>) -> CGFloat {
    return graphs
        .filter { !$0.isHidden }
        .flatMap { $0.column }
        .max() ?? 0
}

func currentMaxY (for graphs: Array<Graph>, from: CGFloat, to: CGFloat) -> CGFloat {
    return graphs
        .filter { !$0.isHidden }
        .flatMap { slice($0.column, lower: from, upper: to) }
        .max() ?? 0
}


func bound(_ value: CGFloat, to lowerValue: CGFloat, upper: CGFloat) -> CGFloat {
    return min(max(value, lowerValue), upper)
}
