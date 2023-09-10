////
////  PieSliceView.swift
////  sabusuku
////
////  Created by hashimo ryoya on 2023/09/07.
////
//
//import SwiftUI
//
//// 1. 円グラフのビューを作成する
//struct PieSliceView: View {
//    var startAngle: Angle
//    var endAngle: Angle
//    var color: Color
//    
//    var body: some View {
//        GeometryReader { geometry in
//            Path { path in
//                let width: CGFloat = min(geometry.size.width, geometry.size.height)
//                let center = width / 2
//                let radius = center
//                path.move(to: CGPoint(x: center, y: center))
//                path.addArc(center: CGPoint(x: center, y: center), radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
//            }
//            .fill(color)
//        }
//    }
//}
//
//struct PieChartView: View {
//    var data: [Int]
//    var colors: [Color]
//    
//    var body: some View {
//        GeometryReader { geometry in
//            self.createPieChart(geometry: geometry)
//        }
//    }
//    
//    func createPieChart(geometry: GeometryProxy) -> some View {
//        let total = data.reduce(0, +)
//        var startAngle = Angle(degrees: 0)
//        return ZStack {
//            ForEach(0..<data.count) { index in
//                let slice = Double(data[index]) / Double(total)
//                let endAngle = startAngle + Angle(degrees: 360 * slice)
//                PieSliceView(startAngle: startAngle, endAngle: endAngle, color: colors[index])
//                // startAngleの更新
////                startAngle = endAngle
//            }
//        }
//    }
//}
//
//
//
//// 2. データを円グラフに適用する
//struct SubscriptionGraphView: View {
//    @State private var subscriptions: [Subscription] = [
//        // テストデータ
//        Subscription(serviceName: "Netflix", monthlyFee: 1200, paymentDate: Date(), duration: "1ヶ月", autoRenew: true, notes: ""),
//        Subscription(serviceName: "Hulu", monthlyFee: 800, paymentDate: Date(), duration: "1ヶ月", autoRenew: true, notes: "")
//    ]
//    
//    var body: some View {
//        VStack {
//            PieChartView(data: subscriptions.map { $0.monthlyFee }, colors: subscriptions.map { _ in Color.random })
//            ForEach(subscriptions) { subscription in
//                HStack {
//                    Circle().fill(Color.random).frame(width: 20, height: 20)
//                    Text(subscription.serviceName + " - \(subscription.monthlyFee)円")
//                }
//            }
//        }
//    }
//}
//
//extension Color {
//    static var random: Color {
//        return Color(red: Double.random(in: 0..<1), green: Double.random(in: 0..<1), blue: Double.random(in: 0..<1))
//    }
//}
//
//
//struct PieSliceView_Previews: PreviewProvider {
//    static var previews: some View {
//        SubscriptionGraphView()
//    }
//}
