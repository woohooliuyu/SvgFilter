//
//  SvgFilterApp.swift
//  SvgFilter
//
//  Created by iOS on 2024/5/16.
//

import SwiftUI

@main
struct SvgFilterApp: App {
    var body: some Scene {
        WindowGroup {
            if #available(macOS 12.0, *) {
                ContentView()
            } else {
                // Fallback on earlier versions
            }
        }
    }
}
