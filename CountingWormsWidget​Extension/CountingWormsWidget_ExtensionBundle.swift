//
//  CountingWormsWidget_ExtensionBundle.swift
//  CountingWormsWidget​Extension
//
//  Created by Bram Adams on 2/5/26.
//

import WidgetKit
import SwiftUI

@main
struct CountingWormsWidget_ExtensionBundle: WidgetBundle {
    var body: some Widget {
        CountingWormsWidget_Extension()
        LockScreenCalorieWidget()
    }
}
