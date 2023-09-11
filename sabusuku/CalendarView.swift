//
//  CalendarView.swift
//  sabusuku
//
//  Created by hashimo ryoya on 2023/09/08.
//

import SwiftUI
import Firebase
import FSCalendar

struct CalendarView: UIViewRepresentable {
    typealias UIViewType = FSCalendar

    @State var paymentDates: [Date] = []
    @Binding var currentCalendarPage: Date
    @Binding var selectedDate: Date?
    @Binding var shouldReloadData: Bool

    func makeUIView(context: Context) -> FSCalendar {
        let calendar = FSCalendar()
        calendar.delegate = context.coordinator
        calendar.locale = Locale(identifier: "ja_JP")
        calendar.headerHeight = 0.0  // この行を追加
        calendar.appearance.weekdayTextColor = .darkGray
        return calendar
    }

    func updateUIView(_ uiView: FSCalendar, context: Context) {
        if shouldReloadData {
            uiView.reloadData()
            DispatchQueue.main.async {
                self.shouldReloadData = false
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, FSCalendarDelegate, FSCalendarDelegateAppearance {
        var parent: CalendarView

        init(_ parent: CalendarView) {
            self.parent = parent
        }
        
        func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
            parent.$currentCalendarPage.wrappedValue = calendar.currentPage
        }
        
        func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
            parent.selectedDate = date  // 選択された日付を更新
            print("Selected date in CalendarView: \(parent.selectedDate!)")  // この行を追加
        }
        
        func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
            let weekday = Calendar.current.component(.weekday, from: date)
            if weekday == 7 || weekday == 1 { // 7は土曜日、1は日曜日
                return UIColor.gray // 灰色に変更
            }
            return nil // 他の曜日はデフォルトの色を使用
        }
        
        // 日付の背景色を設定するメソッド
        func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillDefaultColorFor date: Date) -> UIColor? {
            print("Method called")
            
            let calendarComponent = Calendar.current
            let dateComponents = calendarComponent.dateComponents([.year, .month, .day], from: date)
            
            for paymentDate in parent.paymentDates {
                let paymentDateComponents = calendarComponent.dateComponents([.year, .month, .day], from: paymentDate)
                print("dateComponents:\(dateComponents)")
                print("paymentDateComponents:\(paymentDateComponents)")
                if dateComponents == paymentDateComponents {
                    print("Matched date:\(date)")
                    return .red // 支払日には赤色を設定
                }
            }
            return nil
        }

    }
}

struct CalendarView1: View {
    @State var subscriptions: [Subscription] = []  // ここを変更
    @State private var currentCalendarPage: Date = Date()
    @State private var selectedDate: Date? = nil
    @State private var shouldReloadData: Bool = false

//    init(paymentDates: [Date]) {
//        _paymentDates = State(initialValue: paymentDates)  // Initialize paymentDates here
//    }
    
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
                Text("\(selectedDateFormatter.string(from: currentCalendarPage))")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                Spacer()
                Text("")
            }
            .frame(maxWidth:.infinity,maxHeight:60)
            .background(Color("plus"))
            .foregroundColor(Color("fontGray"))
            let paymentDates = subscriptions.map { $0.paymentDate }
                   
                   CalendarView(paymentDates: paymentDates, currentCalendarPage: $currentCalendarPage, selectedDate: $selectedDate, shouldReloadData: $shouldReloadData)
                               .frame(height: 400)
                               .onChange(of: selectedDate) { newValue in
                                   print("Selected date in CalendarView1: \(newValue)")
                               }
                if let date = selectedDate {
                    // 選択された日付に関連するサブスクリプションを表示する新しいセクション
                    ScrollView{
                        VStack {
                            
                            ForEach(subscriptions.filter { Calendar.current.isDate($0.paymentDate, inSameDayAs: date) }, id: \.id) { subscription in
                                VStack{
                                    HStack{
                                        Text("\(subscription.serviceName)")
                                            .font(.system(size: 30))
                                        Spacer()
                                    }
                                    HStack{
                                        Spacer()
                                        Text("の支払日です")
                                    }
                                }
                                .padding()
                                .background(.white)
                                .cornerRadius(10)
                                .shadow(radius: 1)
                            }
                            .padding()
                        }
                    }
            }
            Spacer()
        }
        .frame(maxWidth: .infinity,alignment: .leading)
            .background(Color("sky"))  // この行を追加
        .onAppear {
            fetchPaymentDates()
        }
    }
    

    func fetchPaymentDates() {
        let ref = Database.database().reference().child("subscriptions")
        ref.observe(.value, with: { snapshot in
            var loadedSubscriptions: [Subscription] = []
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                   let dict = childSnapshot.value as? [String: Any],
                   let id = UUID(uuidString: childSnapshot.key),
                   let subscription = Subscription(from: dict, id: id) {
                    loadedSubscriptions.append(subscription)
                }
            }
            self.subscriptions = loadedSubscriptions  // ここを変更
        })
    }
}

struct CalendarView1_Previews: PreviewProvider {
    // 'static'キーワードを追加して、samplePaymentDatesを静的変数にします
    static let samplePaymentDates: [Date] = [Date()]
    
    static var previews: some View {
        CalendarView1()  // ここを修正
    }
}
