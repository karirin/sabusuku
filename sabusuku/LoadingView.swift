//
//  LoadingView.swift
//  Goal
//
//  Created by hashimo ryoya on 2023/07/10.
//

import SwiftUI

struct LoadingView: View {
    @State private var isAnimating = false
    @State private var rotationDegrees: [Double] = [0, 0, 0]
    @State private var startTrim: [CGFloat] = [0, 0, 0]
    @State private var trimTo: CGFloat = 120.0 / 360.0
    @State private var shouldRotate = true
    @State private var opacity = 1.0

    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    @State private var percentage: Int = 0
    let timer2 = Timer.publish(every: 0.3, on: .main, in: .common).autoconnect()

    @State private var expandGreenCircle = false

    var body: some View {
        GeometryReader { geometry in
            ForEach(0..<1) { index in
                Circle()
                    .trim(from: 0, to: 0.9)
                    .stroke(lineWidth: 3)
                    .frame(width: CGFloat(100 + 30 * index), height: CGFloat(100 + 30 * index))
                    .foregroundColor(Color("plus"))
                    .rotationEffect(Angle.degrees(CGFloat(index*50)+rotationDegrees[index]))
                    .animation(shouldRotate ? Animation.linear(duration: 1).repeatForever(autoreverses: false) : .default)
                    .opacity(opacity)
            }
        }
        .onAppear() {
            startTrim = startTrim.map { _ in CGFloat.random(in: 0...1) }
        }
        .onReceive(timer) { _ in
            if shouldRotate {
                withAnimation(Animation.linear(duration: 1).repeatForever(autoreverses: false)) {
                    rotationDegrees = rotationDegrees.enumerated().map { index, degree in
                        degree + (30.0 * Double(1 - Double(index) * 0.2))
                    }
                }
            }
        }
    }
}


struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}
