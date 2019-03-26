//
//  ChartTableViewCell.swift
//  TelegramChart
//
//  Created by Ivan Serebryakov on 21/03/2019.
//  Copyright © 2019 Ivan Serebryakov. All rights reserved.
//

import Foundation
import UIKit

fileprivate let chartSelectorHeight: CGFloat = 60
fileprivate let kVisibleLabelsCount = 6

fileprivate let kTransitionDuration = 0.2
fileprivate let kLineResizeDuration = 0.35
fileprivate let kAnimationPendingDuration = 0.1

fileprivate let kGridLineCount = 5
fileprivate let kYGridTopOffset: CGFloat = 30
fileprivate let kUpperScaleLimit = 5

final class ChartTableViewCell : UITableViewCell {
    
    // MARK: - Public
    
    public var chart: Chart?
    
    public func setChart(_ chart: Chart) {
        chartSelector.setChart(chart)
    }
    
    public var onSelectorChartUpdateCallback: ((_ chart: Chart) -> Void)?
    
    // MARK: - View
    
    private lazy var scrollView: UIScrollView = {
        var view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = false
        return view
    }()
    
    private lazy var lineView: UIImageView = {
        var view = UIImageView()
        view.contentMode = .scaleToFill
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var xAsixValuesView: UIView = {
        var view = UIView()
        return view
    }()
    
    private lazy var chartSelector: ChartRangeSelector = {
        var selector = ChartRangeSelector()
        selector.translatesAutoresizingMaskIntoConstraints = false
        selector.addTarget(self,
                           action: #selector(rangeSliderValueChanged(_:)),
                           for: .valueChanged)
        selector.addTarget(self,
                           action: #selector(rangeSliderValueInit(_:)),
                           for: .applicationReserved)
        return selector
    }()
    
    private lazy var gridLayer: CALayer = {
        var layer = CALayer()
        layer.masksToBounds = true
        return layer
    }()

    private lazy var gridTransition: CATransition = {
        var transition = CATransition()
        transition.duration = kTransitionDuration
        transition.timingFunction = CAMediaTimingFunction(name: .easeIn)
        transition.type = .moveIn
        return transition
    }()
    
    private lazy var pendingWork = WorkItem()
    
    private var scale: CGFloat = 1
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.layer.addSublayer(gridLayer)
        contentView.addSubview(chartSelector)
        contentView.addSubview(scrollView)
        
        scrollView.addSubview(lineView)
        scrollView.addSubview(xAsixValuesView)
        
        contentView.layer.masksToBounds = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let chart = chart else { return }
        
        scrollView.frame = CGRect(x: frame.minX + 15,
                                  y: bounds.minY + 30,
                                  width: bounds.width - 30,
                                  height: bounds.height - 120)

        chartSelector.frame = CGRect(x: frame.minX + 15,
                                     y: frame.height - 60,
                                     width: bounds.width - 30,
                                     height: 60)
        
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width * chart.horizontalScale,
                                        height: scrollView.frame.size.height)
        gridLayer.frame = scrollView.frame
        xAsixValuesView.frame.size = scrollView.contentSize
        lineView.frame.size = scrollView.contentSize
        gridLayer.masksToBounds = true
        
        chartSelector.resizeCallback = {
            [unowned self]
            (lower, scale) in
            self.scrollView.setContentOffset(CGPoint(x: (self.scrollView.contentSize.width) * lower,
                                                     y: self.scrollView.contentOffset.y),
                                             animated: false)
            self.scrollView.contentSize.width = self.scrollView.frame.width * scale
            self.lineView.frame.size.width = self.scrollView.contentSize.width
        }
        
        initialDraw()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private var xLinesLabels: Array<[CATextLayer]> = []
    
    // MARK: - Draw
    
    func drawLines (_ chart: Chart) -> CALayer {
        return drawChart(chart,
                         size: lineView.bounds.size,
                         lineWidth: 2.0)
    }
    
    func drawYGrid (_ max: CGFloat) -> CALayer {
        return drawGridLines(size: gridLayer.frame.size,
                                   count: kGridLineCount,
                                   max: max)
    }
    
    func createXLabels (from values: [Int], _ upperScaleLimit: Int = kUpperScaleLimit) -> Array<[CATextLayer]> {
        return Array(1...upperScaleLimit)
            .lazy
            .map { sliceFullRange(values, take: $0 * kVisibleLabelsCount - 1) }
            .map { $0.map { $0 |> (toDate >>> format >>> drawLabel) } }
    }
    
    // MARK: - Slider Actions
    
    @objc
    func rangeSliderValueInit(_ rangeSlider: ChartRangeSelector) {
        self.chart = rangeSlider.chart
        guard let chart = rangeSlider.chart, !(gridLayer.frame.size == .zero) else { return }
        chart
            |> drawLines >>> rasterizeLayer >=> updateImage
        chart.currentMaxY
            |> drawYGrid >=> updateYGrid
        chart.verticalScale
            >=> resize
    }
    
    @objc
    func rangeSliderValueChanged(_ rangeSlider: ChartRangeSelector) {
        guard let rangeChart = rangeSlider.chart else { return }
        guard let chart = self.chart else { return }
        
        if !(chart.roundedScale.isEqual(to: rangeChart.roundedScale)) {
            if rangeChart.roundedScale.truncatingRemainder(dividingBy: 0.5) == 0 {
                updateXLabels(lables: self.xLinesLabels, scale: rangeChart.roundedScale)
                rangeChart
                    |> drawLines >>> rasterizeLayer >=> updateImage
            }
        }
        
        if !(chart.currentMaxY.isEqual(to: rangeChart.currentMaxY)) {
            pendingWork.perform(after: kAnimationPendingDuration) { [unowned self] in
                self.gridTransition.subtype =
                    (chart.currentMaxY > rangeChart.currentMaxY)
                        ? .fromTop
                        : .fromBottom
                
                rangeChart
                    |> self.drawLines >>> rasterizeLayer >=> self.updateImage
                rangeChart.currentMaxY
                    |> self.drawYGrid >=> self.updateYGrid
                rangeChart.verticalScale
                    >=> self.resize
            }
        }
        
        onSelectorChartUpdateCallback?(rangeChart)
        self.chart = rangeChart
    }
    
    // MARK: -
    // MARK: - Side
    // MARK: -
    
    func resize (_ scale: CGFloat) {
        UIView.animate(withDuration: kLineResizeDuration) {
            let offset = self.scrollView.bounds.height * (1 / scale)
            self.lineView.frame = CGRect(x: 0,
                                         y: self.scrollView.frame.height - offset,
                                         width: self.scrollView.contentSize.width,
                                         height: offset)
        }
    }
    
    func updateImage(_ image: UIImage?) {
        self.lineView.image = image
    }
    
    func updateYGrid(_ layer: CALayer) {
        self.gridLayer.sublayers?.removeAll()
        self.gridLayer.addSublayer(layer)
        
        layer.add(gridTransition, forKey: kCATransition)
    }
    
    func updateXLabels (lables: Array<[CATextLayer]>, scale: CGFloat) {
        xAsixValuesView.layer.sublayers?.removeAll()
        
        for (index, value) in lables[Int(scale - 1)]
            .enumerated() {
            value.frame = CGRect(x: xAsixValuesView.frame.minY + (xAsixValuesView.frame.width / CGFloat(kVisibleLabelsCount) * CGFloat(index)),
                                 y: xAsixValuesView.frame.height - 15,
                                 width: 40,
                                 height: 22)
            
            xAsixValuesView.layer.addSublayer(value)
        }
    }
    
    func initialDraw() {
        guard let chart = chart else { return }
        chart
            |> drawLines >>> rasterizeLayer >=> updateImage
        chart.currentMaxY
            |> drawYGrid >=> updateYGrid
        chart.verticalScale
            >=> resize
        
        xLinesLabels = createXLabels(from: chart.x)
        updateXLabels(lables: xLinesLabels, scale: (1 / chart.roundedScale))
        
        self.chart = chart
    }
    
    
}
