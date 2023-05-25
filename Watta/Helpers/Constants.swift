//
//  Constants.swift
//  Watta
//
//  Created by Sarah Uli Octavia on 25/05/23.
//

import Foundation

struct Constants {
    // Dummy model
    static var sampleModel = HydrationModel(amounts: [10, 100, 100])
    
    // Configuration Constants
    struct Config {
        // UserDefaults Keys
        static let saveKey = "key"
        static let dateKey = "date"
        static let goalKey = "goal"
        
        // Slider increments
        static let baseGoal:Double = 2000
        static let waterIndex:Double = 1000
        
        // water goal increments
        static let weightIndex:Double = 10
        static let waterIndex2: Double = Constants.Config.waterIndex/2
        static let waterIndex3: Double = Constants.Config.waterIndex/50
        static let goalIncrement:Double = 200
    }
    // Default values
    struct defaultValues {
        

        static let goal:Double = Constants.Config.baseGoal
        static let goalIndex:Double = 50
    }
    
}
