//
//  SubscriptionListView.swift
//  sabusuku
//
//  Created by hashimo ryoya on 2023/09/06.
//

import SwiftUI
import Firebase

struct Subscription: Identifiable {
    var id = UUID()
    var serviceName: String
    var monthlyFee: Int
    var paymentDate: Date
    var duration: String
    var autoRenew: Bool
    var notes: String
    var paymentHistory: [Date] = []
    var isSwiped: Bool = false
}

struct SubscriptionListView: View {
    @State private var subscriptions: [Subscription] = []
    @State private var sortedSubscriptionsList: [Subscription] = []
    @State private var hasNewPaymentHistory: Bool = false
    @State var showAnotherView_post: Bool = false
    @ObservedObject var authManager = AuthManager.shared
    @State private var showingDeleteAlert = false
    @State private var selectedSubscription: Subscription?
    @State private var offset: CGFloat = 0
    @State private var isSwiped: Bool = false
    
    enum SortOption {
        case nearestPaymentDate
        case farthestPaymentDate
        case highestFee
        case lowestFee
    }
    
    @State private var currentSortOption: SortOption = .nearestPaymentDate
    
    func formattedDate(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/M/d"
        return formatter.string(from: date)
    }
    
    var body: some View {
        ZStack(alignment: .trailing) {
        NavigationView {
            VStack(alignment: .leading,spacing: 10) {
                HStack{
                    ZStack {
                        Image(systemName: "bell")
                            .foregroundColor(.black)
                            .font(.system(size: 30))
                        if hasNewPaymentHistory { // 新規の支払い履歴が存在する場合に表示
                            Image(systemName: "circle.fill")
                                .resizable()
                                .frame(width: 15, height: 15)
                                .foregroundColor(.red)
                                .offset(x: 10, y: -10)
                        }
                    }
                    .padding(.trailing)
                    .opacity(0)
                    Spacer()
                    Text("サブスクリプション一覧")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                    Spacer()
                    NavigationLink(destination: PaymentHistoryView()) {
                        ZStack {
                            Image(systemName: "bell")
                                .foregroundColor(.white)
                                .font(.system(size: 25))
//                            if hasNewPaymentHistory { // 新規の支払い履歴が存在する場合に表示
                                Image(systemName: "circle.fill")
                                    .resizable()
                                    .frame(width: 10, height: 10)
                                    .foregroundColor(.red)
                                    .offset(x: 5, y: -5)
//                            }
                        }
                    }
                    .padding(.trailing)
                    .onDisappear { // この修飾子を追加
                                        self.hasNewPaymentHistory = false
                                    }
                }
                .frame(maxWidth:.infinity,maxHeight:60)
                .background(Color("plus"))
                .foregroundColor(Color("fontGray"))
                HStack{
                    Spacer()
                    Picker(selection: $currentSortOption, label: Text("Select a post")){
                        Text("支払日が近い順").tag(SortOption.nearestPaymentDate)
                        Text("支払日が遠い順").tag(SortOption.farthestPaymentDate)
                        Text("料金が大きい順").tag(SortOption.highestFee)
                        Text("料金が小さい順").tag(SortOption.lowestFee)
                    }
                    .accentColor(Color("fontGray"))
                    .onChange(of: currentSortOption) { newValue in
                        sortedSubscriptionsList = sortedSubscriptions()
                    }
                    .font(.system(size: 30))
                        .overlay(
                        RoundedRectangle(cornerRadius: 100)
                            .stroke(.black.opacity(3), lineWidth: 1)
                        
                    )
                }
                .padding(.trailing)
                ScrollView {
                ForEach(sortedSubscriptionsList.indices, id: \.self) { index in
                    let subscription = sortedSubscriptionsList[index]
                        ZStack(alignment: .trailing) {
                        NavigationLink(destination: SubscriptionDetailView(subscription: subscription)) {
                            VStack(alignment: .leading) {
                                Text(subscription.serviceName)
                                    .font(.system(size: 30))
                                HStack{
                                    Text("月額料金: \(subscription.monthlyFee)円")
                                        .multilineTextAlignment(.leading)
                                    Text("支払い日: \(formattedDate(from: subscription.paymentDate))")
                                }
                            }
                            .foregroundColor(Color("fontGray"))
                            .frame(maxWidth: .infinity,alignment: .leading)
                            .background(.white)
                            .cornerRadius(8)
                            .offset(x: self.subscriptions[index].isSwiped ? -100 : 0)
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        if value.translation.width < 0 {
                                            self.subscriptions[index].isSwiped = true
                                        }
                                    }
                                    .onEnded { value in
                                        if -value.translation.width > 100 {
                                            self.subscriptions[index].isSwiped = true
                                        } else {
                                            self.subscriptions[index].isSwiped = false
                                        }
                                    }
                            )
                        }
                            if self.subscriptions[index].isSwiped {
                                Button(action: {
                                    self.selectedSubscription = subscription
                                    self.showingDeleteAlert = true
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.white)
                                        .frame(width: 44, height: 44)
                                        .background(Color.red)
                                        .cornerRadius(22)
                                }
                                .frame(width: 100, height: 44)
                                .transition(.move(edge: .trailing))
                            }
                        }
                        
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 1)
                        .padding(.horizontal)
                        .padding(.vertical,5)
                }
            }
        }
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
        }        .alert(isPresented: $showingDeleteAlert) {
            Alert(title: Text("確認"),
                  message: Text("\(selectedSubscription?.serviceName ?? "")を削除しますか？"),
                  primaryButton: .destructive(Text("削除")) {
                      if let subscription = self.selectedSubscription {
                          deleteSubscription(subscription)
                      }
                  },
                  secondaryButton: .cancel(Text("キャンセル")))
        }
        .onAppear(perform: {
            loadData()
            sortedSubscriptionsList = sortedSubscriptions()
        })
    }
    
    func deleteSubscriptionAtIndex(at offsets: IndexSet) {
        for index in offsets {
            let subscription = sortedSubscriptionsList[index]
            deleteSubscription(subscription)
        }
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
    
    func sortedSubscriptions() -> [Subscription] {
        switch currentSortOption {
        case .nearestPaymentDate:
            return subscriptions.sorted(by: { $0.paymentDate < $1.paymentDate })
        case .farthestPaymentDate:
            return subscriptions.sorted(by: { $0.paymentDate > $1.paymentDate })
        case .highestFee:
            return subscriptions.sorted(by: { $0.monthlyFee > $1.monthlyFee })
        case .lowestFee:
            return subscriptions.sorted(by: { $0.monthlyFee < $1.monthlyFee })
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
            print(subscription)
            saveUpdatedPaymentDate(for: subscription)
        }
    }
    
    func deleteSubscription(_ subscription: Subscription) {
        let ref = Database.database().reference().child("subscriptions").child(subscription.id.uuidString)
        ref.removeValue { (error, _) in
            if let error = error {
                print("サブスクリプションの削除に失敗しました: \(error.localizedDescription)")
            } else {
                print("サブスクリプションを削除しました!")
                if let index = self.subscriptions.firstIndex(where: { $0.id == subscription.id }) {
                    self.subscriptions.remove(at: index)
                }
            }
        }
    }
    
    func loadData() {
        guard let userId = self.authManager.currentUserId else {
            print("ユーザーIDが取得できませんでした")
            return
        }
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
                   var subscription = Subscription(from: dict, id: id) {
                    
                    updatePaymentDate(for: &subscription)
                    
                    if let subscriptionUserId = dict["userId"] as? String, subscriptionUserId == userId {
                        loadedSubscriptions.append(subscription)

                        if let lastUpdatedDate = dict["lastUpdatedDate"] as? String, lastUpdatedDate == currentDateString {
                            hasNewPaymentHistory = true
                        }
                    }
                }
            }
            
            DispatchQueue.main.async {
                self.subscriptions = loadedSubscriptions
                self.sortedSubscriptionsList = self.sortedSubscriptions() // この行を追加
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
