//
//  PieChartView.swift
//  sabusuku
//
//  Created by hashimo ryoya on 2023/09/07.
//

import SwiftUI
import Charts
import FirebaseDatabase

struct SubscriptionGraphView: View {
    @State private var subscriptions: [Subscription] = []

    var body: some View {
        VStack {
            if subscriptions.isEmpty {
                Text("データを読み込んでいます...")
                    .onAppear {
                        fetchSubscriptions { fetchedSubscriptions in
                            subscriptions = fetchedSubscriptions
                        }
                    }
            } else {
                PieChartView1(data: createChartData(subscriptions: subscriptions))
            }
        }
    }
    
    func fetchSubscriptions(completion: @escaping ([Subscription]) -> Void) {
        var fetchedSubscriptions: [Subscription] = []
        
        let ref = Database.database().reference().child("subscriptions")
        ref.observeSingleEvent(of: .value) { snapshot in
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                   let dict = childSnapshot.value as? [String: Any],
                   let serviceName = dict["serviceName"] as? String,
                   let monthlyFee = dict["monthlyFee"] as? Int,
                   let paymentDate = dict["paymentDate"] as? String,
                   let duration = dict["duration"] as? String,
                   let autoRenew = dict["autoRenew"] as? Bool,
                   let notes = dict["notes"] as? String {
                    
                    let subscription = Subscription(serviceName: serviceName, monthlyFee: monthlyFee, paymentDate: Date(), duration: duration, autoRenew: autoRenew, notes: notes)
                    fetchedSubscriptions.append(subscription)
                }
            }
            completion(fetchedSubscriptions)
        }
    }
    
    func createChartData(subscriptions: [Subscription]) -> PieChartData {
        let dataEntries = subscriptions.map { ChartDataEntry(x: Double($0.id.hashValue), y: Double($0.monthlyFee), data: $0.serviceName) }
        let dataSet = PieChartDataSet(entries: dataEntries, label: "")
//        print("subscriptions:\(subscriptions)")
//        print("dataEntries:\(dataEntries)")
//        print("dataSet:\(dataSet)")
        dataSet.colors = ChartColorTemplates.material()
        
        // サービス名のフォントと色を設定
        dataSet.valueFont = .systemFont(ofSize: 12)
        dataSet.valueTextColor = .black
        
        // 各データエントリのテキストカラーを黒色に設定
        let numberOfEntries = dataEntries.count
        dataSet.valueColors = Array(repeating: .black, count: numberOfEntries)
        
        // subscriptions.serviceNameを表示するためのカスタムフォーマッター
        dataSet.valueFormatter = DefaultValueFormatter { (value, entry, index, viewPortHandler) -> String in
            print("test")
            print("entry.data:\(entry.data)")
            return entry.data as? String ?? ""
        }
        
        return PieChartData(dataSet: dataSet)
    }

}

struct PieChartView1: View {
    var data: PieChartData
    
    var body: some View {
        PieChart(data: data)
            .frame(height: 300)
    }
}

struct PieChart: UIViewRepresentable {
    var data: PieChartData

    func makeUIView(context: Context) -> PieChartView {
        let chart = PieChartView()
        chart.data = data
        
        // エントリのラベルと値を表示する設定を追加
        chart.drawEntryLabelsEnabled = true
//        chart.drawValuesEnabled = true

        
        return chart
    }


    func updateUIView(_ uiView: PieChartView, context: Context) {
        uiView.data = data
    }
}

struct SubscriptionGraphView_Previews: PreviewProvider {
    static var previews: some View {
        SubscriptionGraphView()
    }
}
