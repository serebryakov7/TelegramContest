//
//  Drawer.swift
//  TelegramChart
//
//  Created by Ivan Serebryakov on 21/03/2019.
//  Copyright © 2019 Ivan Serebryakov. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics

func drawLine(from start: CGPoint,
              to end: CGPoint,
              color: UIColor = .black,
              lineWidth: CGFloat = 2.0) -> CAShapeLayer
{
    let layer = CAShapeLayer()
    let linePath = UIBezierPath()
    
    linePath.move(to: start)
    linePath.addLine(to: end)
    
    layer.path = linePath.cgPath
    layer.lineWidth = lineWidth
    layer.strokeColor = color.cgColor
    
    return layer
}

func drawLabel(_ value: String) -> CATextLayer {
    let layer = CATextLayer()
    
    layer.foregroundColor = Theme.shared.additionalTextColor.cgColor
    layer.alignmentMode = .left
    layer.contentsScale = UIScreen.main.scale
    layer.font = CTFontCreateWithName(UIFont.systemFont(ofSize: 0).fontName as CFString, 0, nil)
    layer.fontSize = 12
    layer.string = value
    
    return layer
}



func drawChart(_ chart: Chart, size: CGSize, lineWidth: CGFloat) -> CALayer {
    let chartLayer = CALayer()
    chartLayer.frame.size = size
    
    let width = chartLayer.frame.width
    let height = chartLayer.frame.height
    
    let graphs = chart.graphs
        .filter{ !$0.isHidden }
    
    let elements = graphs
        .flatMap{ $0.column }
    
    let minY = CGFloat(elements.min() ?? 0)
    let maxY = CGFloat(elements.max() ?? 0)
    
    let stepX = width / CGFloat(chart.x.count)
    let rangeY = maxY - minY

    for graph in graphs {
        let layer = CAShapeLayer()
        let path = UIBezierPath()
        
        path.move(to:
            CGPoint(
                x: 0,
                y: height * (maxY - graph.column[0]) / rangeY
            )
        )
        
        for i in 1..<graph.column.count {
            let point = CGPoint(x: CGFloat(i) * stepX,
                                y: height * (maxY - graph.column[i]) / rangeY)
            path.addLine(to: point)
        }
        
        layer.path = path.cgPath
        layer.lineJoin = .round
        layer.fillColor = nil
        layer.lineWidth = lineWidth
        layer.strokeColor = graph.color.cgColor
        chartLayer.addSublayer(layer)
    }
    
    return chartLayer
}

func drawGridLabels(width: CGFloat, count: Int) -> [CAShapeLayer] {
    return
        (1...count)
        .compactMap { _ in
            drawLine(from: CGPoint(x: 0,
                                   y: 0),
                     to: CGPoint(x: width,
                                 y: 0),
                     color: Theme.shared.additionalColor,
                     lineWidth: 0.5) }
}

func drawHorizontalLineLables(size: CGSize, count: Int, max: CGFloat, min: CGFloat) -> Array<CATextLayer> {
    return stride(from: min, to: max, by: max / CGFloat(count))
        .map { drawLabel($0 |> (Int.init(_:) >>> String.init(_:))) }
    
}

func drawGridLines(size: CGSize, count: Int, max: CGFloat = 1, min: CGFloat = 0) -> CALayer {
    let gridLayer = CALayer()
    gridLayer.frame.size = size
    
    let lineLayer = drawGridLabels(width: size.width, count: count)
    let valueLayer = drawHorizontalLineLables(size: size, count: count, max: max, min: min)
    
    stride(from: 0, to: size.height, by: size.height / CGFloat(count))
        .enumerated()
        .compactMap {
            valueLayer[$0].frame = CGRect(x: 0,
                                          y: size.height - $1 - 16,
                                          width: size.width,
                                          height: 16)
            lineLayer[$0].frame.origin = CGPoint(x: 0,
                                                 y: size.height - $1)
            gridLayer.addSublayer(valueLayer[$0])
            gridLayer.addSublayer(lineLayer[$0]) }
    
    return gridLayer
}
