//
//  SubscriptionListView.swift
//  sabusuku
//
//  Created by hashimo ryoya on 2023/09/06.
//

import SwiftUI
import Firebase

struct SubscriptionListView: View {
    @State private var subscriptions: [Subscription] = []
    @State private var hasNewPaymentHistory: Bool = false
    @State var showAnotherView_post: Bool = false
    
    func formattedDate(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/M/d"
        return formatter.string(from: date)
    }
    
    var body: some View {
        NavigationView {
        ScrollView {
            VStack(alignment: .leading,spacing: 10) {
                HStack{
                    Spacer()
                    // 他のUI要素
                    NavigationLink(destination: PaymentHistoryView()) {
                        ZStack {
                            Image(systemName: "bell")
                                .foregroundColor(.black)
                                .font(.system(size: 35))
                            if hasNewPaymentHistory { // 新規の支払い履歴が存在する場合に表示
                                Image(systemName: "circle.fill")
                                    .resizable()
                                    .frame(width: 15, height: 15)
                                    .foregroundColor(.red)
                                    .offset(x: 10, y: -10)
                            }
                        }
                    }
                    .onDisappear { // この修飾子を追加
                                        self.hasNewPaymentHistory = false
                                    }
                }
                .padding()
                ForEach(subscriptions) { subscription in
                    NavigationLink(destination: SubscriptionDetailView(subscription: subscription)) {
                        VStack(alignment: .leading) {
                            Text(subscription.serviceName)
                                .font(.system(size: 30))
                            HStack{
                                Text("月額料金: \(subscription.monthlyFee)円")
                                    .multilineTextAlignment(.leading)
                                Text("支払い日: \(formattedDate(from: subscription.paymentDate))")
                                
                                //                        Text("期間: \(subscription.duration)")
                                //                        Text("自動更新: \(subscription.autoRenew ? "有" : "無")")
                                //                        Text("メモ: \(subscription.notes)")
                            }
                        }
                        .padding()
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity,alignment: .leading)
                        .background(.white)
                        .cornerRadius(8)
                    }
                }.padding(.horizontal)
                    .padding(.vertical,5)
                    .shadow(radius: 1)
            }
        }
        .onAppear(perform: loadData)
        .background(Color("sky"))
        .overlay(
            ZStack {
                Spacer()
                HStack {
                    Spacer()
                    VStack{
                        Spacer()
                        HStack {
                            Spacer()
                            Button(action: {
                                self.showAnotherView_post = true
                            }, label: {
                                Image(systemName: "plus")
                                    .foregroundColor(.white)
                                    .font(.system(size: 24))
                            }).frame(width: 60, height: 60)
                                .background(Color("plus"))
                                .cornerRadius(30.0)
                            //                                .shadow(color: Color(.black).opacity(0.2), radius: 8, x: 0, y: 4
                                .shadow(radius: 5)
                                .fullScreenCover(isPresented: $showAnotherView_post, content: {
                                    SubscriptionView()
                                })
                                .padding()
                        }
                    }
                }
            }
        )
    }
        
        .frame(maxWidth: .infinity)
    }
    
    func dateComponents(from duration: String) -> DateComponents? {
        switch duration {
        case "1ヶ月":
            return DateComponents(month: 1)
        case "2ヶ月":
            return DateComponents(month: 2)
        case "3ヶ月":
            return DateComponents(month: 3)
        case "4ヶ月":
            return DateComponents(month: 4)
        case "5ヶ月":
            return DateComponents(month: 5)
        case "6ヶ月":
            return DateComponents(month: 6)
        case "7ヶ月":
            return DateComponents(month: 7)
        case "8ヶ月":
            return DateComponents(month: 8)
        case "9ヶ月":
            return DateComponents(month: 9)
        case "10ヶ月":
            return DateComponents(month: 10)
        case "11ヶ月":
            return DateComponents(month: 11)
        case "12ヶ月":
            return DateComponents(month: 12)
        default:
            return nil
        }
    }
    
    func saveUpdatedPaymentDate(for subscription: Subscription) {
        let ref = Database.database().reference().child("subscriptions").child(subscription.id.uuidString)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        
        let updatedPaymentDateString = dateFormatter.string(from: subscription.paymentDate)
        let paymentHistoryStrings = subscription.paymentHistory.map { dateFormatter.string(from: $0) }
        
        // 現在の日付を"yyyy-MM-dd"の形式で取得
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let currentDateString = dateFormatter.string(from: Date())
        
        var valuesToUpdate: [String: Any] = ["paymentDate": updatedPaymentDateString, "lastUpdatedDate": currentDateString, "paymentHistory": paymentHistoryStrings]
        
        ref.updateChildValues(valuesToUpdate) { (error, ref) in
            if let error = error {
                print("支払日の更新に失敗しました: \(error.localizedDescription)")
            } else {
                print("支払日を更新しました!")
            }
        }
    }


    func updatePaymentDate(for subscription: inout Subscription) {
        let currentDate = Date()
        var isUpdated = false
        if let durationComponents = dateComponents(from: subscription.duration) {
            while subscription.paymentDate <= currentDate {
                if let newPaymentDate = Calendar.current.date(byAdding: durationComponents, to: subscription.paymentDate) {
                    subscription.paymentHistory.append(subscription.paymentDate) // ここで支払日を履歴に追加
                    subscription.paymentDate = newPaymentDate
                    isUpdated = true
                } else {
                    break
                }
            }
        }
        if isUpdated {
            saveUpdatedPaymentDate(for: subscription)
        }
    }
    
    func loadData() {
        let ref = Database.database().reference().child("subscriptions")
        ref.observe(.value) { snapshot in
            var loadedSubscriptions: [Subscription] = []
            
            let currentDate = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let currentDateString = dateFormatter.string(from: currentDate)
            
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                   let dict = childSnapshot.value as? [String: Any],
                   let id = UUID(uuidString: childSnapshot.key),
                   let subscription = Subscription(from: dict, id: id) {
                    
                    loadedSubscriptions.append(subscription) // すべてのサブスクリプションを追加
                    
                    if let lastUpdatedDate = dict["lastUpdatedDate"] as? String, lastUpdatedDate == currentDateString {
                        hasNewPaymentHistory = true // 新規の支払い履歴が存在する場合に変数を更新
                    }
                }
            }
            
            DispatchQueue.main.async {
                self.subscriptions = loadedSubscriptions
            }
        }
    }

}

extension Subscription {
    init?(from dict: [String: Any], id: UUID) {
        guard let serviceName = dict["serviceName"] as? String,
              let monthlyFee = dict["monthlyFee"] as? Int,
              let paymentDateString = dict["paymentDate"] as? String,
              let duration = dict["duration"] as? String,
              let autoRenew = dict["autoRenew"] as? Bool,
              let notes = dict["notes"] as? String else {
            return nil
        }
        
        // 文字列からDate型への変換
         let dateFormatter = DateFormatter()
         dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        if let paymentHistoryStrings = dict["paymentHistory"] as? [String] {
            self.paymentHistory = paymentHistoryStrings.compactMap { dateFormatter.date(from: $0) }
        } else {
            self.paymentHistory = []
        }
        
        
         guard let paymentDate = dateFormatter.date(from: paymentDateString) else {
             print("Error converting date for service: \(serviceName)")
             return nil
         }

         // previousPaymentDateの取得
//         var previousPaymentDate: Date? = nil
//         if let prevPaymentDateString = dict["previousPaymentDate"] as? String {
//             previousPaymentDate = dateFormatter.date(from: prevPaymentDateString)
//         }

         self.id = id
         self.serviceName = serviceName
         self.monthlyFee = monthlyFee
         self.paymentDate = paymentDate
         self.duration = duration
         self.autoRenew = autoRenew
         self.notes = notes
//         self.previousPaymentDate = previousPaymentDate // ここでセット
     }
}

struct SubscriptionListView_Previews: PreviewProvider {
    static var previews: some View {
        SubscriptionListView()
    }
}
