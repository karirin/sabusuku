//
//  SubscriptionForm.swift
//  sabusuku
//
//  Created by hashimo ryoya on 2023/09/06.
//

import SwiftUI
import Firebase

//struct Subscription: Identifiable {
//    var id = UUID()
//    var serviceName: String
//    var monthlyFee: Int
//    var paymentDate: Date
//    var duration: String
//    var autoRenew: Bool
//    var notes: String
//}

struct SubscriptionView: View {
    @State private var serviceName: String = ""
    @State private var monthlyFee: Int = 0
    @State private var paymentDate = Date()
    @State private var duration: Int = 1  // 初期値を1ヶ月に設定
    @State private var autoRenew: Bool = true
    @State private var notes: String = ""
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @ObservedObject var authManager = AuthManager.shared

    // サブスクリプションの期間の選択肢
    let durations = Array(1...12)  // 1ヶ月から12ヶ月までの配列

    var body: some View {
        NavigationView {
            VStack{
                List{
                    Section(header: Text("サービス情報")) {
                        HStack{
                            Text("サービス名")
                                .bold()
                            Spacer()
                            TextField("Netflix", text: $serviceName)
                                .multilineTextAlignment(.trailing)
                        }
                        HStack{
                            Text("料金")
                                .bold()
                            Spacer()
                            TextField("1980", value: $monthlyFee,formatter: NumberFormatter())
                                .multilineTextAlignment(.trailing)
                            Text("円")
                                .bold()
                        }
                        DatePicker("支払い日", selection: $paymentDate, displayedComponents: .date)
                            .environment(\.locale, Locale(identifier: "ja_JP"))
                            .bold()
                        // Pickerを使用してサブスクリプションの期間を選択
                        Picker("サブスクリプションの期間", selection: $duration) {
                            ForEach(durations, id: \.self) { month in
                                Text("\(month)ヶ月").tag(month)
                            }
                        }.bold()
                        
                        Toggle("自動更新", isOn: $autoRenew)
                            .bold()
                        
                    }
                    
                    Section(header: Text("メモ")) {
                        TextField("プレミアムプランで契約", text: $notes)
                        .frame(height:200, alignment: .top)                }
                    
//                    Button("登録") {
//                        let newSubscription = Subscription(serviceName: serviceName, monthlyFee: monthlyFee, paymentDate: paymentDate, duration: "\(duration)ヶ月", autoRenew: autoRenew, notes: notes)
//                        let ref = Database.database().reference()
//                        // データベースに保存
//                        let subscriptionDict: [String: Any] = [
//                            "serviceName": newSubscription.serviceName,
//                            "monthlyFee": newSubscription.monthlyFee,
//                            "paymentDate": "\(newSubscription.paymentDate)",
//                            "duration": newSubscription.duration,
//                            "autoRenew": newSubscription.autoRenew,
//                            "notes": newSubscription.notes
//                        ]
//
//                        ref.child("subscriptions").child(newSubscription.id.uuidString).setValue(subscriptionDict)
//                    }
                    
                }
                .listStyle(.grouped)
                .background(Color("sky"))
                .scrollContentBackground(.hidden)
                .navigationBarTitle("ユーザー登録", displayMode: .inline)
                .navigationBarBackButtonHidden(true)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("戻る") {
                            self.presentationMode.wrappedValue.dismiss()
                        }
                        .foregroundColor(.black)
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("登録") {
                            guard let userId = self.authManager.currentUserId else {
                                                print("ユーザーIDが取得できませんでした")
                                                return
                                            }
                            
                            let newSubscription = Subscription(serviceName: serviceName, monthlyFee: monthlyFee, paymentDate: paymentDate, duration: "\(duration)ヶ月", autoRenew: autoRenew, notes: notes)
                            let ref = Database.database().reference()
                            // データベースに保存
                            let subscriptionDict: [String: Any] = [
                                "serviceName": newSubscription.serviceName,
                                "monthlyFee": newSubscription.monthlyFee,
                                "paymentDate": "\(newSubscription.paymentDate)",
                                "duration": newSubscription.duration,
                                "autoRenew": newSubscription.autoRenew,
                                "notes": newSubscription.notes,
                                "userId": userId
                            ]
                            
                            ref.child("subscriptions").child(newSubscription.id.uuidString).setValue(subscriptionDict)
                            
                            self.presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
            }
        }
    }
}


struct SubscriptionForm_Previews: PreviewProvider {
    static var previews: some View {
        SubscriptionView()
    }
}
