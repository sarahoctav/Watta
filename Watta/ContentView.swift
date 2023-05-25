//
//  ContentView.swift
//  Watta
//
//  Created by Sarah Uli Octavia on 25/05/23.
//

import SwiftUI

struct ContentView: View {
    private var health: HealthModel
    private var hydration: HydrationModel
    
    init() {
        health = HealthModel()
        hydration = HydrationModel(healthModel: health)
    }
    
    var body: some View {
        VStack{
            HomeView(hydration: hydration, health: health)
        }.onAppear {
            // On appearance, request authorization of HealthKit
            /// (App works without authorization)
            health.requestAuthorization { success in
                if !success {
                    print("Access not granted!")
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
