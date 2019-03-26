//
//  Graph2.swift
//  TelegramChart
//
//  Created by Ivan Serebryakov on 21/03/2019.
//  Copyright © 2019 Ivan Serebryakov. All rights reserved.
//


import UIKit

public struct Chart: Decodable {
    var x: Array<Int> = []
    var graphs: Array<Graph> = []
//    
//    var lowerValue: CGFloat = 0.3
//    var upperValue: CGFloat = 0.8
    
    var currentMaxY: CGFloat = 0
    var totalMaxY: CGFloat = 0
    
    var horizontalScale: CGFloat = 0
    var verticalScale: CGFloat = 0
    var roundedScale: CGFloat = 0
    
    private enum ChartCodingKey : String, CodingKey {
        case names
        case colors
        case columns
        case types
    }
    
    init(columns: [[Column]], types: [String: String], names: [String: String], colors: [String: String]) {
        for column in columns {
            var elements = Array<CGFloat>()
            var key = ""
            
            column.forEach {
                switch $0 {
                case .int(let value): elements.append(CGFloat(value))
                case .string(let value): key = value
                }
            }
            
            if key == ColumnType.x.rawValue {
                self.x = elements.map { Int($0) }
            } else {
                guard let color = colors[key],
                    let name = names[key],
                    let typeRaw = types[key],
                    let type = ColumnType(rawValue: typeRaw)
                    else { fatalError() }
                
                self.graphs.append(Graph(column: elements,
                                         color: UIColor(hexString: color),
                                         name: name,
                                         type: type,
                                         isHidden: false))
            }
        }
    }
    
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ChartCodingKey.self)
        
        let columns = try container.decode([[Column]].self, forKey: .columns)
        let types = try container.decode([String: String].self, forKey: .types)
        let names = try container.decode([String: String].self, forKey: .names)
        let colors = try container.decode([String: String].self, forKey: .colors)
        self.init(columns: columns, types: types, names: names, colors: colors)
    }
}

public enum Column : Decodable {
    case int(Int)
    case string(String)
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let x = try? container.decode(Int.self) {
            self = .int(x)
            return
        }
        if let x = try? container.decode(String.self) {
            self = .string(x)
            return
        }
        
        throw DecodingError.typeMismatch(Column.self,
                                         DecodingError.Context(codingPath: decoder.codingPath,
                                                               debugDescription: "Value is neither string nor int"))
    }
}
