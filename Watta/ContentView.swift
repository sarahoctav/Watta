//
//  ContentView.swift
//  Watta
//
//  Created by Sarah Uli Octavia on 25/05/23.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var health : HealthModel
    @EnvironmentObject var hydration : HydrationModel
    
    var body: some View {
        VStack{
            HomeView()
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
