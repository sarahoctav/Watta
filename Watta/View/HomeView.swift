//
//  HomeView.swift
//  Watta
//
//  Created by Sarah Uli Octavia on 25/05/23.
//

import SwiftUI

struct HomeView: View {
//    init(hydration:HydrationModel, health:HealthModel  ) {
//        self.hydration = hydration
//        self.health = health
//        UITableView.appearance().backgroundColor = .clear }
    @EnvironmentObject var health : HealthModel
    @EnvironmentObject var hydration : HydrationModel
//    @ObservedObject var health:HealthModel
//    @ObservedObject var hydration:HydrationModel
    @State var addIntakeSheet = false
    @State var phase: CGFloat = 0.0
    @State var progress: Double = 0.0
//    @State var percent: String = ""
    
    var body: some View {
        VStack{
            // MARK: - Total Intake
            Text("\(hydration.totalIntake) ml")
                .font(.system(size: 50, design: .rounded))
                .fontWeight(.semibold)
                .foregroundColor(AppColor.main_color)
                .padding(.top)
            if (Double(hydration.totalIntake)/health.goal * 100) == 0 {
                Text("0 %")
                    .font(.system(size: 24, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundColor(AppColor.tertiary_color)
            }else{
                Text("\((Double(hydration.totalIntake)/health.goal * 100).noTrailingZero()) %")
                    .font(.system(size: 24, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundColor(AppColor.tertiary_color)
            }
            // MARK: - Water Progress
            ZStack{
                Image("tear-drop").resizable()
                GeometryReader { geometry in
                    WaterWave(progress: hydration.progress, phase: self.phase)
                        .fill(AppColor.main_color)
                }.onAppear(){
                    withAnimation(Animation.linear(duration: 1).repeatForever(autoreverses: false)){
                        self.phase = .pi * 2
                    }
                }
            }
            .mask {
                Image("tear-drop").resizable()
            }
            .frame(width: 260, height: 350)
            .padding(.bottom,40)
            
            if health.exerciseDuration >= 20 {
                HStack {
                    VStack(alignment: .trailing) {
                        Text("your fluid goal")
                            .font(.subheadline)
                            .padding(.bottom,-5)
                        HStack (alignment: .center){
                            Text("\(health.goal.noTrailingZero()) ml")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Image(systemName: "arrow.up.circle.fill")
                                .frame(width: 10,height: 10)
                        }
                        
                    }
                    .padding(.trailing,-12)
                    .frame(maxWidth: 150)
                    
                    Divider()
                        .frame(width: 1, height: 50)
                        .background(AppColor.main_color)
                    
                    VStack{
                        Text("Your fluid goal has increased after \(health.exerciseDuration.noTrailingZero()) minutes of exercise")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .italic()
                            .padding(.horizontal,6)
                            .frame(maxWidth: 150)
                        
                    }
                    
                }
                .foregroundColor(AppColor.secondary_color)
                .padding()
                .padding(.bottom,30)
                
            }else{
                HStack (alignment:.center){
                    VStack(alignment: .trailing) {
                        Text("your fluid goal")
                            .font(.callout)
                        HStack (alignment: .center){
                            Text("\(health.goal.noTrailingZero()) ml")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                        }
                        
                    }
                    .padding(.trailing,-12)
                    .frame(maxWidth: 150)
                    
                    Divider()
                        .frame(width: 1, height: 50)
                        .background(AppColor.main_color)
                    
                    VStack{
                        Text("Water up! Stay on track and stay hydrated💧")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .italic()
                            .padding(.horizontal,6)
                            .frame(maxWidth: 150)
                        
                    }
                }
                .foregroundColor(AppColor.secondary_color)
                .padding()
                .padding(.bottom,30)
            }
            
            // MARK: - Add Water Intake
            Button(action: { addIntakeSheet.toggle()}, label: {
                //                Image("add-bottle")
                //                    .resizable()
                //                    .scaledToFit()
                ////                    .shadow(color: .white, radius: 6)
                //                    .frame(maxWidth: 60, maxHeight: 70, alignment: .center)
                //                    .padding()
                Text("Add Water")
                    .fontWeight(.semibold)
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .padding(.horizontal,50)
                    .background(AppColor.main_color)
                    .cornerRadius(20)
                
            })
            .padding()
            .padding(.bottom)
            .sheet(isPresented: $addIntakeSheet, content: {
                AddWaterIntake(hydration: hydration)
            })
            
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            ZStack {
                GeometryReader { geometry in
                    WaterWave(progress: 0.37, applitude:18, phase: 40, normalizedWave: false)
                        .fill(AppColor.main_color)
                        .edgesIgnoringSafeArea(.all)
                }
                .onAppear(){
                    withAnimation(Animation.linear(duration: 1).repeatForever(autoreverses: false)){
                        self.phase = .pi * 2
                    }
                }
                .opacity(0.10)
                GeometryReader { geometry in
                    WaterWave(progress: 0.36, applitude: 18, phase: 30, normalizedWave: false)
                        .fill(AppColor.main_color)
                        .edgesIgnoringSafeArea(.all)
                }
                .opacity(0.10)
            }
        )
        .onAppear{
            DispatchQueue.main.async{
                NotificationModel.instance.setupNotifications()
                hydration.updateProgress()
                self.progress = hydration.progress
            }
        }
        .onChange(of: self.progress){ newValue in
            withAnimation {
                DispatchQueue.main.async{
                    hydration.updateProgress()
                    self.progress = hydration.progress
                    
                }
            }
        }
        
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView().environmentObject(HealthModel())
            .environmentObject(HydrationModel())
    }
}

