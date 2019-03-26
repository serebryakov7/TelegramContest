//
//  WorkItem.swift
//  TelegramChart
//
//  Created by Ivan Serebryakov on 23/03/2019.
//  Copyright © 2019 Ivan Serebryakov. All rights reserved.
//

import Foundation
import UIKit

final class WorkItem {
    private var pendingRequestWorkItem: DispatchWorkItem?
    
    func perform(after: TimeInterval, _ block: @escaping () -> ()) {
        pendingRequestWorkItem?.cancel()
        let requestWorkItem = DispatchWorkItem(block: block)
        pendingRequestWorkItem = requestWorkItem
        DispatchQueue.main.asyncAfter(deadline: .now() + after, execute: requestWorkItem)
    }
}
