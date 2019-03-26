//
//  Helpers.swift
//  TelegramChart
//
//  Created by Ivan Serebryakov on 24/03/2019.
//  Copyright © 2019 Ivan Serebryakov. All rights reserved.
//

import Foundation
import CoreGraphics
import UIKit

func toDate(timestamp: Int) -> Date {
    return Date(timeIntervalSince1970: TimeInterval(timestamp))
}

func format(date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMM d"
    return dateFormatter.string(from: date)
}

func minMaxValues(array: Array<CGFloat>) -> (CGFloat, CGFloat) {
    return (array.min() ?? 0, array.max() ?? 0)
}

func sliceFullRange<T>(_ array: Array<T>, take: Int) -> Array<T> {
    let step = Int(array.count / take)
    var tempArray = Array<T>()
    for i in stride(from: 0, to: array.count, by: step) {
        tempArray.append(array[i])
    }
    return tempArray
}

func slice<T>(_ array: Array<T>, lower: CGFloat, upper: CGFloat) -> Array<T> {
    return Array(array[Int(Float(array.count) * fabsf(Float(lower)))..<Int(Float(array.count) * fabsf(Float(upper)))])
}

func rasterizeLayer(_ layer: CALayer) -> UIImage? {
    UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, 0)
    
    guard let context = UIGraphicsGetCurrentContext() else { return nil }
    layer.render(in: context)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    
    UIGraphicsEndImageContext()
    
    return image
}
