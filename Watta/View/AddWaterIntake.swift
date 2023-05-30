//
//  AddWaterIntake.swift
//  Watta
//
//  Created by Sarah Uli Octavia on 25/05/23.
//

import SwiftUI

struct AddWaterIntake: View {
    // View writes to a hydration model
    var hydration:HydrationModel
    
    // presentationMode property used to close the sheet
    @Environment(\.presentationMode) var presentationMode
    
    // animation water wave
    @State var progress: CGFloat = 0.0
    @State var phase: CGFloat = 0.0
    @State var amountWater: Int = 0
    
    var body: some View {
        NavigationView {
            VStack(spacing:30){
                ZStack{
                    Image("bottle").resizable()
                    GeometryReader { geometry in
                        WaterWave(progress: self.progress, phase: self.phase)
                            .fill(AppColor.main_color)
                            .gesture(DragGesture(minimumDistance: 0)
                                .onChanged({value in
                                    self.progress = 1 - (value.location.y/geometry.size.height)
                                }))
                    }
                    .onAppear(){
                        withAnimation(Animation.linear(duration: 1).repeatForever(autoreverses: false)){
                            self.phase = .pi * 2
                        }
                    }
                    Text("\((self.progress.rounded(toPlaces: 2) * Double(Constants.Config.waterIndex)).noTrailingZero()) ml")
                        .font(.system(size: 50, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                .mask {
                    Image("bottle").resizable()
                }
                .frame(width: 220, height: 480)
                
                // Slider button
                Slider(value: self.$progress, in: 0...1)
                    .frame(width: 250)
                    .accentColor(AppColor.main_color)
                    .padding()
                
                
                
                
            }
            .toolbar{
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back"){
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("Add Water Intake").font(.headline)
                    
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add"){
                        hydration.addIntake(amount: amountWater, drink: 0)
                        self.presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(amountWater == 0)
                }
            }
            .onAppear{
                withAnimation {
                    DispatchQueue.main.async{
                        amountWater = Int((self.progress.rounded(toPlaces: 2) * Double(Constants.Config.waterIndex)).noTrailingZero())!
                    }
                }
            }
            .onChange(of: self.progress){ newValue in
                withAnimation {
                    DispatchQueue.main.async{
                        amountWater = Int((self.progress.rounded(toPlaces: 2) * Double(Constants.Config.waterIndex)).noTrailingZero())!
                    }
                }
            }
        }
        .background(Color.white.edgesIgnoringSafeArea(.all))
        
        
    }
}

struct AddWaterIntake_Previews: PreviewProvider {
    static var previews: some View {
        AddWaterIntake(hydration: Constants.sampleModel)
    }
}
