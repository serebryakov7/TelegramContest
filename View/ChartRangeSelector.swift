//
//  ChartRangeSelector.swift
//  TelegramChart
//
//  Created by Ivan Serebryakov on 21/03/2019.
//  Copyright © 2019 Ivan Serebryakov. All rights reserved.
//

import UIKit

fileprivate struct ChartRangeSelectorConstants {
    static let thumbWidth: CGFloat = 13.0
    static let lowerBound: CGFloat = 0.0
    static let upperBound: CGFloat = 1.0
}

final class RangeSliderHighlightableLayer : CALayer {
    var isHighlighted = false
}

final class ChartRangeSelector : UIControl {
    
    private var upper: CGFloat = 0.8
    private var lower: CGFloat = 0.3
    
    public var chart: Chart?
    
    // FIXME: Property observers
    public func setChart(_ chart: Chart) {
        updateChartValues(chart)
        draw(chart: chart)
        resizeCallback?(lower, chart.horizontalScale)
        sendActions(for: .applicationReserved)
    }
    
    public var resizeCallback: ((CGFloat, CGFloat) -> Void)?
    
    // MARK: - Subviews
    
    private lazy var trackLayer: CALayer = {
        var layer = CALayer()
        layer.backgroundColor = Theme.shared.mainColor.cgColor
        return layer
    }()
    
    private lazy var leftBackgroundLayer: CALayer = {
        var layer = CALayer()
        layer.backgroundColor = UIColor.black.cgColor
        layer.opacity = 0.25
        return layer
    }()
    
    private lazy var rightBackgroundLayer: CALayer = {
        var layer = CALayer()
        layer.backgroundColor = UIColor.black.cgColor
        layer.opacity = 0.25
        return layer
    }()
    
    private lazy var leftDraggableLayer: RangeSliderHighlightableLayer = {
        var layer = RangeSliderHighlightableLayer()
        layer.cornerRadius = 2.0
        layer.masksToBounds = true
        layer.maskedCorners = [
            .layerMinXMinYCorner,
            .layerMinXMaxYCorner
        ]
        return layer
    }()
    
    private lazy var rightDraggableLayer: RangeSliderHighlightableLayer = {
        var layer = RangeSliderHighlightableLayer()
        layer.cornerRadius = 2.0
        layer.masksToBounds = true
        layer.maskedCorners = [
            .layerMaxXMinYCorner,
            .layerMaxXMaxYCorner
        ]
        return layer
    }()
    
    private lazy var centerDraggableLayer: RangeSliderHighlightableLayer = {
        let layer = RangeSliderHighlightableLayer()
        return layer
    }()
    
    private lazy var topBorderLayer: CALayer = {
        var layer = CALayer()
        return layer
    }()
    
    private lazy var bottomBorderLayer: CALayer = {
        var layer = CALayer()
        return layer
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.addSublayer(trackLayer)
        layer.addSublayer(leftBackgroundLayer)
        layer.addSublayer(rightBackgroundLayer)
        layer.addSublayer(leftDraggableLayer)
        layer.addSublayer(rightDraggableLayer)
        layer.addSublayer(topBorderLayer)
        layer.addSublayer(bottomBorderLayer)
        layer.addSublayer(centerDraggableLayer)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let chart = chart else { return }
        
        updateChartValues(chart)
    }
    
    // MARK: - Control tracking
    
    private var previousLocation = CGPoint()
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        previousLocation = touch.location(in: self)
        
        if centerDraggableLayer.frame.contains(previousLocation) { centerDraggableLayer.isHighlighted.toggle() }
        if leftDraggableLayer.frame.contains(previousLocation) { leftDraggableLayer.isHighlighted.toggle() }
        if rightDraggableLayer.frame.contains(previousLocation) { rightDraggableLayer.isHighlighted.toggle() }
        
        return leftDraggableLayer.isHighlighted || rightDraggableLayer.isHighlighted || centerDraggableLayer.isHighlighted
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        leftDraggableLayer.isHighlighted = false
        rightDraggableLayer.isHighlighted = false
        centerDraggableLayer.isHighlighted = false
    }
    
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        guard let chart = chart else { return false }
        let location = touch.location(in: self)
        
        let deltaLocation = CGFloat(location.x - previousLocation.x)
        let deltaValue = deltaLocation / (bounds.width - ChartRangeSelectorConstants.thumbWidth)
        
        previousLocation = location
        
        if centerDraggableLayer.isHighlighted {
            lower += deltaValue
            upper += deltaValue
                guard
                    lower > ChartRangeSelectorConstants.lowerBound
                        &&
                    upper < ChartRangeSelectorConstants.upperBound
                else { return true }
            lower = bound(lower, to: 0.0, upper: upper - 0.2)
            upper = bound(upper, to: lower + 0.2, upper: 1.0)
        } else if leftDraggableLayer.isHighlighted {
            lower += deltaValue
            lower = bound(lower, to: 0.0, upper: upper - 0.2)
        } else if rightDraggableLayer.isHighlighted {
            upper += deltaValue
            upper = bound(upper, to: lower + 0.2, upper: 1.0)
        }

        updateChartValues(chart)
        updateLayerFrames(chart)
        
        sendActions(for: .valueChanged)
        return true
    }
    
    func updateChartValues(_ chart: Chart) {
        var chart = chart
        
        chart.totalMaxY = totalMaxY(for: chart.graphs)
        chart.currentMaxY = currentMaxY(for: chart.graphs, from: lower, to: upper)
        chart.horizontalScale = horizontalScale(from: lower, to: upper)
        chart.verticalScale = verticleScale(from: chart.totalMaxY, to: chart.currentMaxY)
        chart.roundedScale = chart.horizontalScale.rounded(toPlaces: 1)
        
        resizeCallback?(lower, chart.horizontalScale)
        
        self.chart = chart
    }
    
    func updateColors() {
        trackLayer.backgroundColor = Theme.shared.mainColor.cgColor
        leftDraggableLayer.backgroundColor = Theme.shared.controlColor.cgColor
        rightDraggableLayer.backgroundColor = Theme.shared.controlColor.cgColor
        topBorderLayer.backgroundColor = Theme.shared.controlColor.cgColor
        bottomBorderLayer.backgroundColor = Theme.shared.controlColor.cgColor
    }
    
    func updateLayerFrames(_ chart: Chart) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        let leftX = bounds.width * lower
        let rightX = bounds.width * upper - ChartRangeSelectorConstants.thumbWidth
        
        leftDraggableLayer.frame = CGRect(x: leftX,
                                          y: 0.0,
                                          width: ChartRangeSelectorConstants.thumbWidth,
                                          height: bounds.height)
        rightDraggableLayer.frame = CGRect(x: rightX,
                                           y: 0.0,
                                           width: ChartRangeSelectorConstants.thumbWidth,
                                           height: bounds.height)
        
        centerDraggableLayer.frame = CGRect(x: leftDraggableLayer.frame.maxX,
                                            y: leftDraggableLayer.frame.minY,
                                            width: rightDraggableLayer.frame.minX - leftDraggableLayer.frame.maxX,
                                            height: leftDraggableLayer.frame.height)
        
        updateBorder()
        updateBackgroundLayer()
        CATransaction.commit()
    }

    // MARK: - Draw
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        initialDraw()
    }
    
    func initialDraw() {
        guard let chart = chart else { return }
        
        updateColors()
        updateMainLayer()
        drawLeftArrow()
        drawRightArrow()
        updateLayerFrames(chart)
        draw(chart: chart)
    }
    
    func updateMainLayer() {
        trackLayer.frame = CGRect(x: 0.0,
                                  y: 3.0,
                                  width: bounds.width,
                                  height: bounds.height - 6)
    }
    
    func updateBackgroundLayer() {
        leftBackgroundLayer.frame = CGRect(x: trackLayer.frame.origin.x + ChartRangeSelectorConstants.thumbWidth,
                                           y: trackLayer.frame.origin.y,
                                           width: leftDraggableLayer.frame.origin.x,
                                           height: trackLayer.frame.height)
        rightBackgroundLayer.frame = CGRect(x: rightDraggableLayer.frame.origin.x + ChartRangeSelectorConstants.thumbWidth,
                                            y: trackLayer.frame.origin.y,
                                            width: trackLayer.frame.width - rightDraggableLayer.frame.origin.x -    ChartRangeSelectorConstants.thumbWidth * 2,
                                            height: trackLayer.frame.height)
    }
    
    func drawLeftArrow() {
        leftDraggableLayer.frame = CGRect(x: bounds.width * lower,
                                          y: 0.0,
                                          width: ChartRangeSelectorConstants.thumbWidth,
                                          height: bounds.height)
        leftDraggableLayer.sublayers?.removeAll()
    
        drawLine(from: CGPoint(x: ChartRangeSelectorConstants.thumbWidth / 2 + 3,
                               y: bounds.height / 2 - 7),
                 to: CGPoint(x: ChartRangeSelectorConstants.thumbWidth / 2 - 3,
                             y: bounds.height / 2),
                 color: Theme.shared.controllArrowColor)
            >=> leftDraggableLayer.addSublayer
        drawLine(from: CGPoint(x: ChartRangeSelectorConstants.thumbWidth / 2 - 3,
                               y: bounds.height / 2),
                 to: CGPoint(x: ChartRangeSelectorConstants.thumbWidth / 2 + 3,
                             y: bounds.height / 2 + 7),
                 color: Theme.shared.controllArrowColor)
            >=> leftDraggableLayer.addSublayer
    }
    
    func drawRightArrow() {
        rightDraggableLayer.frame = CGRect(x: bounds.width * upper - ChartRangeSelectorConstants.thumbWidth,
                                           y: 0.0,
                                           width: ChartRangeSelectorConstants.thumbWidth,
                                           height: bounds.height)
        rightDraggableLayer.sublayers?.removeAll()
    
        drawLine(from: CGPoint(x: ChartRangeSelectorConstants.thumbWidth / 2 - 3,
                               y: bounds.height / 2 - 7),
                 to: CGPoint(x: ChartRangeSelectorConstants.thumbWidth / 2 + 3,
                             y: bounds.height / 2),
                 color: Theme.shared.controllArrowColor)
            >=> rightDraggableLayer.addSublayer
        drawLine(from: CGPoint(x: ChartRangeSelectorConstants.thumbWidth / 2 + 3,
                                    y: bounds.height / 2),
                 to: CGPoint(x: ChartRangeSelectorConstants.thumbWidth / 2 - 3,
                             y: bounds.height / 2 + 7),
                 color: Theme.shared.controllArrowColor)
            >=> rightDraggableLayer.addSublayer
    }
    
    func updateBorder() {
        let lowerThumbX = bounds.width * lower
        let upperThumbX = bounds.width * upper - ChartRangeSelectorConstants.thumbWidth
    
        topBorderLayer.frame = CGRect(x: lowerThumbX + ChartRangeSelectorConstants.thumbWidth,
                                      y: 0.0,
                                      width: upperThumbX - lowerThumbX - ChartRangeSelectorConstants.thumbWidth ,
                                      height: 2.0)
    
        bottomBorderLayer.frame = CGRect(x: lowerThumbX + ChartRangeSelectorConstants.thumbWidth,
                                         y: bounds.height - 2.0,
                                         width: upperThumbX - lowerThumbX - ChartRangeSelectorConstants.thumbWidth,
                                         height: 2.0)
    }
    
    func draw(chart: Chart) {
        trackLayer.sublayers?.removeAll()
        let chartLayer = drawChart(chart,
                                   size: CGSize(width: trackLayer.frame.size.width - ChartRangeSelectorConstants.thumbWidth * 2,
                                                height: trackLayer.frame.size.height),
                                   lineWidth: 1.0)
        
        chartLayer.frame.origin.x = trackLayer.frame.origin.x + ChartRangeSelectorConstants.thumbWidth
            trackLayer.addSublayer(chartLayer)
    }
}
