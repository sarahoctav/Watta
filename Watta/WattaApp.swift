//
//  WattaApp.swift
//  Watta
//
//  Created by Sarah Uli Octavia on 25/05/23.
//

import SwiftUI

@main
struct WattaApp: App {
    @StateObject var healthModel : HealthModel = HealthModel.sharedInstance
    @StateObject var hydrationModel : HydrationModel = HydrationModel()
    var body: some Scene {
 
        WindowGroup {
            ContentView()
                .environmentObject(hydrationModel)
                .environmentObject(healthModel)
        }
    }
}
