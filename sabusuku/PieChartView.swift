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
    @State private var currentDate: Date = Date() // 現在の日付を保持する変数
    @State private var filteredSubscriptions: [Subscription] = []

    var body: some View {
        VStack {
            // 年月の表示
            Text("\(formattedDate(date: currentDate))")
                .font(.title)
                .padding()
                .onChange(of: currentDate) { _ in
                    filterSubscriptionsByDate()
                }
            
            if subscriptions.isEmpty {
                Text("データを読み込んでいます...")
                    .onAppear {
                        fetchSubscriptions { fetchedSubscriptions in
                            subscriptions = fetchedSubscriptions
                            filterSubscriptionsByDate()
                        }
                    }
            } else {
                PieChartView1(data: createChartData(subscriptions: subscriptions))
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(filteredSubscriptions, id: \.serviceName) { subscription in
                        HStack {
                            Text(subscription.serviceName)
                                .font(.headline)
                            Spacer()
                            Text("\(subscription.monthlyFee)円")
                                .font(.subheadline)
                        }
                    }
                }
                .padding()
                .onAppear {
                    fetchSubscriptions { fetchedSubscriptions in
                        subscriptions = fetchedSubscriptions
                        filterSubscriptionsByDate()
                    }
                }
            }
        }
        // スワイプジェスチャーの追加
        .gesture(DragGesture(minimumDistance: 50)
            .onEnded { value in
                if value.translation.width < 0 {
                    // 左にスワイプ -> 1ヶ月追加
                    currentDate = Calendar.current.date(byAdding: .month, value: 1, to: currentDate) ?? currentDate
                } else if value.translation.width > 0 {
                    // 右にスワイプ -> 1ヶ月マイナス
                    currentDate = Calendar.current.date(byAdding: .month, value: -1, to: currentDate) ?? currentDate
                }
            }
        )
    }
    
    // Dateを"yyyy/MM"形式の文字列に変換する関数
    func formattedDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM"
        return formatter.string(from: date)
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
                   let paymentDateString = dict["paymentDate"] as? String,
                   let duration = dict["duration"] as? String,
                   let autoRenew = dict["autoRenew"] as? Bool,
                   let notes = dict["notes"] as? String {
                    
                    // paymentHistoryStringsの取得をオプショナルに
                    let paymentHistoryStrings = dict["paymentHistory"] as? [String] ?? []
                    
                    // paymentDateStringをDateオブジェクトに変換
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
                    guard let paymentDate = dateFormatter.date(from: paymentDateString) else {
                        print("Error converting date for service: \(serviceName)")
                        continue
                    }
                    
                    let paymentHistory = paymentHistoryStrings.compactMap { dateFormatter.date(from: $0) }
                    
                    let subscription = Subscription(serviceName: serviceName, monthlyFee: monthlyFee, paymentDate: paymentDate, duration: duration, autoRenew: autoRenew, notes: notes, paymentHistory: paymentHistory)
                    fetchedSubscriptions.append(subscription)
                }
            }
            completion(fetchedSubscriptions)
        }
    }


    func createChartData(subscriptions: [Subscription]) -> PieChartData {
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: currentDate)
        let currentMonth = calendar.component(.month, from: currentDate)
        
        // DateFormatterのインスタンスを作成
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        
        // 選択された年月に一致するpaymentDateやpaymentHistoryを持つサブスクリプションをフィルタリング
        let filteredSubscriptions = subscriptions.filter { subscription in
            
//            print("subscription:\(subscription)")
            let subscriptionYear = calendar.component(.year, from: subscription.paymentDate)
            let subscriptionMonth = calendar.component(.month, from: subscription.paymentDate)
            
            if subscriptionYear == currentYear && subscriptionMonth == currentMonth {
                return true
            }
            
            for historyDate in subscription.paymentHistory {
                let historyYear = calendar.component(.year, from: historyDate)
                let historyMonth = calendar.component(.month, from: historyDate)
                if historyYear == currentYear && historyMonth == currentMonth {
                    return true
                }
            }
            
            return false
        }
        
        // フィルタリングされたサブスクリプションのmonthlyFeeを使用して、データエントリを作成
        let dataEntries = filteredSubscriptions.map { ChartDataEntry(x: Double($0.id.hashValue), y: Double($0.monthlyFee), data: $0.serviceName) }
        let dataSet = PieChartDataSet(entries: dataEntries, label: "")
        dataSet.colors = ChartColorTemplates.material()
        
        // サービス名のフォントと色を設定
        dataSet.valueFont = .systemFont(ofSize: 12)
        dataSet.valueTextColor = .black
        
        // 各データエントリのテキストカラーを黒色に設定
        let numberOfEntries = dataEntries.count
        dataSet.valueColors = Array(repeating: .black, count: numberOfEntries)
        
        // subscriptions.serviceNameを表示するためのカスタムフォーマッター
        dataSet.valueFormatter = DefaultValueFormatter { (value, entry, index, viewPortHandler) -> String in
            return entry.data as? String ?? ""
        }
        return PieChartData(dataSet: dataSet)
    }
    
    func filterSubscriptionsByDate() {
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: currentDate)
        let currentMonth = calendar.component(.month, from: currentDate)
        
        filteredSubscriptions = subscriptions.filter { subscription in
            let subscriptionYear = calendar.component(.year, from: subscription.paymentDate)
            let subscriptionMonth = calendar.component(.month, from: subscription.paymentDate)
            if subscriptionYear == currentYear && subscriptionMonth == currentMonth {
                return true
            }
            
            for historyDate in subscription.paymentHistory {
                let historyYear = calendar.component(.year, from: historyDate)
                let historyMonth = calendar.component(.month, from: historyDate)
                if historyYear == currentYear && historyMonth == currentMonth {
                    return true
                }
            }
            
            return false
        }
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
