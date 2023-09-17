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
    @State private var totalAmount: Int = 0
    @State private var chartColors: [UIColor] = []

    let selectedDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月" // 例: 2023年08月22日
        return formatter
    }()

    var body: some View {
        VStack {
            HStack{
                Text("")
                Spacer()
                // 年月の表示
                Text("\(selectedDateFormatter.string(from: currentDate))")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                    .padding()
                    .onChange(of: currentDate) { _ in
                        filterSubscriptionsByDate()
                    }
                Spacer()
                Text("")
            }
            .frame(maxWidth:.infinity,maxHeight:60)
            .background(Color("plus"))
            
//            if subscriptions.isEmpty {
//                LoadingView()
//                    .frame(width: 100, height: 100)  // ローディングビューのサイズを設定します。
//                    .position(x: UIScreen.main.bounds.width / 2.0, y: UIScreen.main.bounds.height / 2.4)
//                    .frame(maxWidth:.infinity,maxHeight:.infinity)
//                    .onAppear {
//                        fetchSubscriptions { fetchedSubscriptions in
//                            subscriptions = fetchedSubscriptions
//                            filterSubscriptionsByDate()
//                        }
//                    }
//            } else
            if filteredSubscriptions.isEmpty {
                VStack{
                    Text("\(selectedDateFormatter.string(from: currentDate))にはデータがありません")
                        .font(.system(size: 20))
                        .foregroundColor(.gray)
                        .padding()
                }.frame(maxWidth:.infinity,maxHeight:.infinity)
                    .onAppear {
                        fetchSubscriptions { fetchedSubscriptions in
                            subscriptions = fetchedSubscriptions
                            filterSubscriptionsByDate()
                        }
                    }
            } else {
                if !subscriptions.isEmpty && !filteredSubscriptions.isEmpty {
                    let chartData = createChartData(subscriptions: subscriptions)
                    PieChartView1(data: chartData)
                    ScrollView{
                        VStack(alignment: .leading,spacing: 5) {
                            HStack{
                                Image(systemName: "calendar")
                                    .foregroundColor(Color("red"))
                                    .font(.system(size: 25))
                                Text("\(selectedDateFormatter.string(from: currentDate))")
                                    .font(.system(size: 25))
                                Spacer()
                                Text("合計: \(totalAmount)")
                                    .font(.system(size: 25))
                                HStack(alignment: .bottom){
                                    Text("円")
                                        .padding(.top,5)
                                        .font(.system(size: 15))
                                }
                            }
                            .font(.system(size: 20))
                            .foregroundColor(Color("fontGray"))
                            .padding(.top, 10)
                            .padding(.horizontal)
                            Divider()
                            ForEach(filteredSubscriptions.indices, id: \.self) { index in
                                let subscription = filteredSubscriptions[index]
                                let color = chartColors.count > index ? chartColors[index] : UIColor.gray // 色の配列のサイズを超えないようにします
                                
                                HStack {
                                    // ここに色を表示するビューを追加
                                    Color(color)
                                        .frame(width: 20, height: 20)
                                        .cornerRadius(10)
                                    
                                    Text(subscription.serviceName)
                                        .font(.system(size: 22))
                                    Spacer()
                                    Image(systemName: "yensign.circle")
                                        .font(.system(size: 20))
                                        .foregroundColor(Color("plus"))
                                    Text("\(subscription.monthlyFee)")
                                        .font(.system(size: 25))
                                    HStack(alignment: .bottom){
                                        Text("円")
                                            .padding(.top,5)
                                            .font(.system(size: 15))
                                    }
                                }
                                .padding(.horizontal)
                                Divider()
                            }
                        }
                        .foregroundColor(Color("fontGray"))
                        .frame(maxWidth:.infinity)
                        .onAppear {
                            fetchSubscriptions { fetchedSubscriptions in
                                subscriptions = fetchedSubscriptions
                                filterSubscriptionsByDate()
                            }
                        }
                    }
                }
            }
            Spacer()
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
    
    func updateChartColors(with colors: [UIColor]) -> some View {
        chartColors = colors
        return EmptyView()
    }

    
    // Dateを"yyyy/MM"形式の文字列に変換する関数
    func formattedDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM"
        return formatter.string(from: date)
    }
    
    func fetchSubscriptions(completion: @escaping ([Subscription]) -> Void) {
        guard let currentUserId = AuthManager.shared.currentUserId else {
            print("Error: No current user ID found.")
            return
        }

        let ref = Database.database().reference().child("subscriptions").queryOrdered(byChild: "userId").queryEqual(toValue: currentUserId)

        ref.observeSingleEvent(of: .value) { snapshot in
            var fetchedSubscriptions: [Subscription] = []
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
        print("test")
        // 選択された年月に一致するpaymentDateやpaymentHistoryを持つサブスクリプションをフィルタリング
        let filteredSubscriptions = subscriptions.filter { subscription in
            
            print("subscription:\(subscription)")
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
        self.chartColors = dataSet.colors
        print("chartColors:\(chartColors)")
                print("dataSet.colors:\(dataSet.colors)")
        
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
        print("test")
        print(subscriptions)
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
        totalAmount = filteredSubscriptions.reduce(0) { $0 + $1.monthlyFee }
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
        
        // エントリのラベルと値を表示する設定
        chart.drawEntryLabelsEnabled = true
        
        // Legendの設定
        chart.legend.enabled = true
        chart.legend.horizontalAlignment = .right
        chart.legend.verticalAlignment = .top
        chart.legend.orientation = .vertical
        chart.legend.drawInside = false
        chart.legend.form = .circle
        
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
