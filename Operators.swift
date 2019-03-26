//
//  Operators.swift
//  TelegramChart
//
//  Created by Ivan Serebryakov on 11/03/2019.
//  Copyright © 2019 Ivan Serebryakov. All rights reserved.
//

import Foundation

precedencegroup ApplyForward {
    associativity: left
    higherThan: AssignmentPrecedence
}

infix operator |> : ApplyForward

func |> <X, Y> (x: X, f: (X) -> Y) -> Y {
    return f(x)
}

precedencegroup ForwardComposition {
    associativity: left
    higherThan: ApplyForward
}

infix operator >>> : ForwardComposition

func >>> <T, U, V>(left: @escaping (T) -> U, right: @escaping (U) -> V) -> (T) -> V {
    return { right(left($0)) }
}

infix operator >=> : ApplyForward

func >=> <X> (x: X, f: (X) -> Void) {
    f(x)
}
