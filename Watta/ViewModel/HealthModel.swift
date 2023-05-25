//
//  HealthModel.swift
//  Watta
//
//  Created by Sarah Uli Octavia on 25/05/23.
//

import Foundation
import HealthKit

class HealthModel: ObservableObject {
    static let sharedInstance = HealthModel()
    
    // MARK: Published Properties
    // main store
    @Published var healthStore:HKHealthStore?
    @Published var exerciseDuration: Double
    @Published var bodyWeight: Double
    
    @Published var processBegan = false
    @Published var success = false
    @Published var goal: Double = 0.0
    
    // MARK: Init
    // initializer (does NOT ask for permission; fails if Healthkit is not available on current platform)
    init() {
        if HKHealthStore.isHealthDataAvailable() {
            healthStore = HKHealthStore()
            exerciseDuration = 0
            bodyWeight = Constants.defaultValues.goalIndex
        } else {
            fatalError("Healthkit not available on this platform!")
        }
    }
    
    // MARK: Request Authorization
    // request authorization from user
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        
        // type of unit the app requests access to (dietary water)
        let waterType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryWater)!
        
        // request exercise duration type
        let exerciseType = HKObjectType.quantityType(forIdentifier: .appleExerciseTime)!
        
        // request body weight
        let weightType = HKObjectType.quantityType(forIdentifier: .bodyMass)!
        
        
        // unwrap the store
        guard let healthStore = self.healthStore else {
            return completion(false)
        }
        
        healthStore.requestAuthorization(toShare: [waterType], read: [exerciseType, weightType]) { (success, error) in
            if let error = error {
                // Handle the authorization error
                print("Authorization failed: \(error.localizedDescription)")
            } else {
                // Authorization succeeded, fetch exercise activity duration
                self.readBodyWeight { bodyWeightInKilograms, error in
                    DispatchQueue.main.async {
                        self.bodyWeight = bodyWeightInKilograms ?? 100.0
                        print("Body Weight -> \(self.bodyWeight)")
                    }
                }
                self.fetchExerciseActivityDuration()
            }
        }
    }
    
    // MARK: Write WaterData to Health
    func writeData(intake:WaterData) {
        
        // Specify quantity type (dietary water)
        let quantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryWater)
        
        // Unwrap the health store
        if let healthStore = self.healthStore {
            
            // Loop for each water data structure
            // Create new healthkit sample (data entry)
            let newSample =
            HKQuantitySample.init(type: quantityType!, quantity: HKQuantity.init(unit: HKUnit.literUnit(with: .milli), doubleValue: Double(intake.amount)), start: intake.date, end: intake.date)
            
            // Store saves new sample
            healthStore.save(newSample) { (success, error) in
                if (error != nil) {
                    print("ERROR WITH SAVING: \(String(describing: error))")
                }
                if success {
                    print("SAVED: \(success)")
                }
            }
        }
    }
    
    // MARK: Read Exercise Duration
    func fetchExerciseActivityDuration() {
        // define the exercise duration type
        let exerciseType = HKObjectType.quantityType(forIdentifier: .appleExerciseTime)!
        
        // create a predicate for the date range you're interested in
        let calendar = Calendar.current
        let now = Date()
        let startDate = calendar.startOfDay(for: now)
        let endDate = calendar.date(byAdding: .day, value: 1, to: startDate)
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictEndDate)
        
        
        // create a query to fetch exercise samples
        let query = HKStatisticsQuery(quantityType: exerciseType, quantitySamplePredicate: predicate, options: .cumulativeSum) { (query, result, error) in
            if let error = error {
                // handle the query error
                print("Query failed: \(error.localizedDescription)")
                return
            }
            
            if let result = result, let sum = result.sumQuantity() {
                // get the exercise duration in seconds
                let exerciseDuration = sum.doubleValue(for: HKUnit.minute())
                
                // handle the exercise duration data
                print("Exercise duration: \(exerciseDuration) seconds")
                DispatchQueue.main.async {
                    self.exerciseDuration = sum.doubleValue(for: HKUnit.minute())

                }
                
            }
        }
        
        // Execute the query
        healthStore!.execute(query)
    }
    

    // MARK: Read Body Weight
    func readBodyWeight(completion: @escaping (Double?, Error?) -> Void) {
        guard let bodyMassType = HKSampleType.quantityType(forIdentifier: .bodyMass) else {
            completion(nil, nil)
            return
        }

        let query = HKSampleQuery(sampleType: bodyMassType, predicate: nil, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { query, samples, error in
            DispatchQueue.main.async {
                guard let samples = samples as? [HKQuantitySample], let sample = samples.first else {
                    //                    print("Query failed sample -> \(sample)")
                    print("Query failed Weight -> \(error!.localizedDescription)")
                    completion(nil, error)
                    return
                }
                
                let bodyWeightInKilograms = sample.quantity.doubleValue(for: .gramUnit(with: .kilo))
                self.bodyWeight = sample.quantity.doubleValue(for: .gramUnit(with: .kilo))
                self.goal = ((self.bodyWeight - (Constants.Config.weightIndex*2)) * Constants.Config.waterIndex3) + Constants.Config.waterIndex + Constants.Config.waterIndex2
                // goal update if there is exercise duration
                if self.exerciseDuration >= 20 {
                    // Calculate the increase amount based on the exercise duration
                    let increaseAmount = floor(self.exerciseDuration / 20) * Constants.Config.goalIncrement
                    
                    self.goal = ((self.bodyWeight - (Constants.Config.weightIndex*2)) * Constants.Config.waterIndex3) + Constants.Config.waterIndex + Constants.Config.waterIndex2 + increaseAmount
                    
                }
                completion(bodyWeightInKilograms, error)
                
            }
//            DispatchQueue.main.async {
//            }


        }

        healthStore!.execute(query)
    }
    
}
