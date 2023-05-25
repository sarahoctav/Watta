//
//  HydrationModel.swift
//  Watta
//
//  Created by Sarah Uli Octavia on 25/05/23.
//

import Foundation
import HealthKit

class HydrationModel: ObservableObject {
    
    
    // MARK: - Properties
    
    // date
    @Published var date:Date
    
    // goal (mL)
    @Published var goal:Double
    
    // progress double (0.0 to 1.0)
    @Published var progress:Double
    
    // total intake (mL)
    @Published var totalIntake:Int
    
    // goal index : corresponds to body weight
    @Published var goalIndex:Double
    
    // intake entries
    @Published private(set) var intake:[WaterData] {
        // When modified, call the save function
        didSet {
            save()
        }
    }
    
    
    
    // Health Model
    @Published var health:HealthModel
    
    
    // MARK: - Initializers
    
    // Initializer takes a Health Model
    init(healthModel: HealthModel) {
        // Default values
        self.goalIndex = healthModel.bodyWeight
        self.goal = healthModel.goal
        self.progress = 0.0
        self.totalIntake = 0
        self.health = healthModel
        self.date = Date()
        
        // Load existing array of entries (it not null)
        if let data = UserDefaults.standard.data(forKey: Constants.Config.saveKey) {
            if let decoded = try? JSONDecoder().decode([WaterData].self, from: data) {
                self.intake = decoded
            } else {
                self.intake = [WaterData]()
            }
        } else {
            self.intake = [WaterData]()
        }
        
        
        // Load last date (if not null) and compare
        if let dateData = UserDefaults.standard.data(forKey: Constants.Config.dateKey) {
            if let decodedDate = try? JSONDecoder().decode(Date.self, from: dateData) {
                
                // If the last date is not the same date as today, log the data
                if !Calendar.current.isDateInToday(decodedDate) {
//                    self.health.saveData(intake: self.intake)
                    self.intake = [WaterData]()
                }
            }
        }
        
        // Load last date (if not null) and compare
        if let goalData = UserDefaults.standard.data(forKey: Constants.Config.goalKey) {
            if let decodedGoalIndex = try? JSONDecoder().decode(Int.self, from: goalData) {
                self.goalIndex = Double(decodedGoalIndex)
            }
        }
        
        self.updateData()
    }
     
    
    // Second initializer with parameter for array of ints for dummy data
    init(amounts:[Int]) {
        self.date = Date()
        self.goalIndex = Constants.defaultValues.goalIndex
        self.goal = ((Constants.defaultValues.goalIndex - (Constants.Config.weightIndex*2)) * Constants.Config.waterIndex3) + Constants.Config.waterIndex + Constants.Config.waterIndex2
        self.progress = 0.0
        self.totalIntake = 0
        self.intake = [WaterData]()
        self.health = HealthModel()
        for i in (0..<amounts.count) {
            self.addIntake(amount: amounts[i], drink: 0)
        }
    }
    
    
    // MARK: - Model Functions
    
    // Save
    private func save() {
        if let encoded = try? JSONEncoder().encode(intake) {
            UserDefaults.standard.set(encoded, forKey: Constants.Config.saveKey)
        }
        
        if let encodedDate = try? JSONEncoder().encode(date) {
            UserDefaults.standard.set(encodedDate, forKey: Constants.Config.dateKey)
        }
        
        if let encodedGoalIndex = try? JSONEncoder().encode(goalIndex) {
            UserDefaults.standard.set(encodedGoalIndex, forKey: Constants.Config.goalKey)
        }
        
    }
    
    
    // Updates total intake and percentage
    private func updateTotal() {
        var total = 0
        for i in (0..<self.intake.count) {
            total += self.intake[i].amount
        }
        self.totalIntake = total
    }
    
    
    // Recalculates to progress double
    func updateProgress() {
        self.progress = min(Double(totalIntake)/Double(health.goal), 1.0)

    }
    

    // Calls updateTotal and updateProgress
    private func updateData() {
        self.updateTotal()
        self.updateProgress()
    }
    
    
    // Add new intake
    func addIntake(amount:Int, drink: Int) {
        self.intake.append(WaterData(amount: amount, drink: drink))
        self.updateData()
        health.writeData(intake:WaterData(amount: amount, drink: drink))
    }
    


}

