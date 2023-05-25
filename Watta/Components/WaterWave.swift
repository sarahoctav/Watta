//
//  WaterWave.swift
//  Watta
//
//  Created by Sarah Uli Octavia on 25/05/23.
//

import Foundation
import SwiftUI

struct WaterWave: Shape {
    var progress: CGFloat
    var applitude: CGFloat = 10
    var waveLength: CGFloat = 20
    //wave animation
    var phase: CGFloat
    var normalizedWave: Bool = true
    var animatableData: CGFloat{
        get { phase }
        set { phase = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let width = rect.width
        let height = rect.height
        let midWidth = width / 2
        let progressHeight = height * (1-progress)
        
        path.move(to: .zero)
        for x in stride(from: 0, to: width, by: 5){
            var relativeX: CGFloat
            var normalizedLength: CGFloat
            if normalizedWave {
                normalizedLength = (x-midWidth)/midWidth
                relativeX = x/waveLength
            } else {
                normalizedLength = 1
                relativeX = x/(waveLength * 2)
            }
            
            let y = progressHeight + sin(phase + relativeX) * applitude * normalizedLength
            path.addLine(to: CGPoint(x:x, y:y))
        }
        path.addLine(to: CGPoint(x:width, y:progressHeight))
        path.addLine(to: CGPoint(x:width, y:height))
        
        path.addLine(to: CGPoint(x:0, y:height))
        path.addLine(to: CGPoint(x:0, y:progressHeight))
        return path
    }
}

struct WaveView: View {
    @State var progress: CGFloat = 0.2
    @State var phase: CGFloat = 0.0
    var body: some View {
        VStack{
            ZStack{
                Image("bottle").resizable()
                GeometryReader { geometry in
                    WaterWave(progress: self.progress, phase: self.phase, normalizedWave: false)
                        .fill(Color.cyan)
                        .gesture(DragGesture(minimumDistance: 0)
                            .onChanged({value in
                                self.progress = 1 - (value.location.y/geometry.size.height)
                            }))
                }.onAppear(){
                    withAnimation(Animation.linear(duration: 1).repeatForever(autoreverses: false)){
                        self.phase = .pi * 2
                    }
                }
            }
            
            .mask {
                Image("bottle").resizable()
            }
            Slider(value: self.$progress, in: 0...1)
        }
    }
}

struct Wave_Previews: PreviewProvider {
    static var previews: some View {
        WaveView()
    }
}
