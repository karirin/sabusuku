//
//  PaymentHistoryView.swift
//  sabusuku
//
//  Created by hashimo ryoya on 2023/09/09.
//

import SwiftUI
import Firebase

struct PaymentHistoryView: View {
    @State private var updatedSubscriptions: [Subscription] = []
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView {
            VStack(spacing: 15) { // ここでVStackを使用して、各アイテム間にスペースを追加します。
                ForEach(updatedSubscriptions) { subscription in
                    VStack(alignment: .leading) {
                        ForEach(subscription.paymentHistory, id: \.self) { paymentDate in
                            VStack(alignment: .leading) {
                                ForEach(subscription.paymentHistory, id: \.self) { paymentDate in
                                    HStack{
                                        Text("\(formattedDate(from: paymentDate))")
                                        Spacer()
                                        VStack{
                                            HStack{
                                                Text("\(subscription.serviceName)")
                                                Spacer()
                                            }.padding(.leading)
                                            HStack{
                                                Spacer()
                                                Text("を支払いました")
                                            }
                                        }
                                        .frame(maxWidth:.infinity).multilineTextAlignment(.leading)
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                    .foregroundColor(Color("fontGray"))
                        .frame(maxWidth: .infinity,alignment: .leading)
                        .background(.white)
                        .cornerRadius(8)
                }
                .shadow(radius: 1)
            }.padding()
        }
        .frame(maxWidth:.infinity,maxHeight:.infinity)
        .background(Color("sky"))
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: {
            self.presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "chevron.left")
                .foregroundColor(.black)
            Text("戻る")
                .foregroundColor(.black)
        })
        .onAppear(perform: loadData)
    }


    func formattedDate(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/M/d"
        return formatter.string(from: date)
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
                   let subscription = Subscription(from: dict, id: id),
                   let lastUpdatedDate = dict["lastUpdatedDate"] as? String {
                    
                    // 最後の更新日が今日の日付と同じであるかを確認
                    if lastUpdatedDate == currentDateString {
                        loadedSubscriptions.append(subscription)
                    }
                }
            }
            
            DispatchQueue.main.async {
                self.updatedSubscriptions = loadedSubscriptions
            }
        }
    }

}

struct PaymentHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        PaymentHistoryView()
    }
}
