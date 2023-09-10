//
//  SubscriptionDetailView.swift
//  sabusuku
//
//  Created by hashimo ryoya on 2023/09/09.
//

import SwiftUI
import Firebase

struct SubscriptionDetailView: View {
    var subscription: Subscription
    @State private var isEditing = false
    func formattedDate(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/M/d"
        return formatter.string(from: date)
    }
    @State private var editedServiceName: String = ""
    @State private var editedMonthlyFee: Int = 0
    @State private var editedPaymentDate: Date = Date()
    @State private var editedDuration: Int = 1
    @State private var editedAutoRenew: Bool = true
    @State private var editedNotes: String = ""
    let durations = Array(1...12)  // 1ヶ月から12ヶ月までの配列

    var body: some View {
            VStack {
                if isEditing {
                    List {
                        HStack{
                            Text("サービス名")
                                .bold()
                            TextField("Netflix", text: $editedServiceName)
                                .multilineTextAlignment(.trailing)
                        }
                        HStack{
                            Text("料金")
                                .bold()
                            Spacer()
                            TextField("1980", value: $editedMonthlyFee,formatter: NumberFormatter())
                                .multilineTextAlignment(.trailing)
                            Text("円")
                                .bold()
                        }
                        DatePicker("支払い日", selection: $editedPaymentDate, displayedComponents: .date)
                            .environment(\.locale, Locale(identifier: "ja_JP"))
                            .bold()
                        // Pickerを使用してサブスクリプションの期間を選択
                        Picker("サブスクリプションの期間", selection: $editedDuration) {
                            ForEach(durations, id: \.self) { month in
                                Text("\(month)ヶ月").tag(month)
                            }
                        }.bold()
                        
                        Toggle("自動更新", isOn: $editedAutoRenew)
                            .bold()
                        Section(header: Text("メモ")) {
                            TextField("プレミアムプランで契約", text: $editedNotes)
                            .frame(height:200, alignment: .top)                }
                    }
                    .listStyle(.grouped)
                    .scrollContentBackground(.hidden)
                }else{
                    ScrollView(.vertical, showsIndicators: false) {
                        Group {
                            HStack{
                                VStack{
                                    Text("サービス名")
                                        .bold()
                                    Spacer()
                                }
                                Spacer()
                                Text(subscription.serviceName)
                            }
                            HStack{
                                VStack{
                                    Text("料金")
                                        .bold()
                                    Spacer()
                                }
                                Spacer()
                                Text("\(subscription.monthlyFee)円")
                            }
                            HStack{
                                VStack{
                                    Text("支払い日")
                                        .bold()
                                    Spacer()
                                }
                                Spacer()
                                Text(formattedDate(from: subscription.paymentDate))
                            }
                            HStack{
                                VStack{
                                    Text("サブスク期間")
                                        .bold()
                                    Spacer()
                                }
                                Spacer()
                                Text("\(subscription.duration)")
                            }
                            HStack{
                                VStack{
                                    Text("自動更新")
                                        .bold()
                                    Spacer()
                                }
                                Spacer()
                                Text("\(subscription.autoRenew ? "有" : "無")")
                            }
                            HStack{
                                VStack{
                                    Text("メモ")
                                        .bold()
                                    Spacer()
                                }
                                Spacer()
                                Text("\(subscription.notes)")
                            }
                        }
                        .padding()
                    }
                }
            }
            .background(Color("sky"))
            .navigationBarTitle(subscription.serviceName, displayMode: .inline)
            .navigationBarItems(trailing: Button(isEditing ? "保存" : "編集") {
                if isEditing {
                    saveChanges()
                } else {
                    // 編集モードに入る前に、編集用の変数を初期化
                    editedServiceName = subscription.serviceName
                    editedMonthlyFee = subscription.monthlyFee
                    editedPaymentDate = subscription.paymentDate
                    editedDuration = Int(subscription.duration.dropLast(2)) ?? 1
                    editedAutoRenew = subscription.autoRenew
                    editedNotes = subscription.notes
                }
                isEditing.toggle()
            })
        }
    func saveChanges() {
        let ref = Database.database().reference().child("subscriptions").child(subscription.id.uuidString)
        
        let updatedData: [String: Any] = [
            "serviceName": editedServiceName,
            "monthlyFee": editedMonthlyFee,
            "paymentDate": "\(editedPaymentDate)",
            "duration": "\(editedDuration)ヶ月",
            "autoRenew": editedAutoRenew,
            "notes": editedNotes
        ]
        
        ref.updateChildValues(updatedData) { (error, _) in
            if let error = error {
                print("データの更新に失敗しました: \(error.localizedDescription)")
            } else {
                print("データを更新しました!")
            }
        }
    }

    }


struct SubscriptionDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let dummySubscription = Subscription(
            serviceName: "Netflix",
            monthlyFee: 1980,
            paymentDate: Date(),
            duration: "1ヶ月",
            autoRenew: true,
            notes: "プレミアムプランで契約"
        )
        return SubscriptionDetailView(subscription: dummySubscription)
    }
}

