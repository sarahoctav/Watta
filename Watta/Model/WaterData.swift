//
//  WaterData.swift
//  Watta
//
//  Created by Sarah Uli Octavia on 25/05/23.
//

import Foundation

struct WaterData: Identifiable, Codable {
    var amount:Int
    var waterID:Int
    var date:Date
    var id:UUID?
    
    init(amount:Int, drink: Int) {
        self.amount = amount
        self.waterID = drink
        self.date = Date()
        self.id = UUID()
    }
}
