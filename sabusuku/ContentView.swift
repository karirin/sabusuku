//
//  ContentView.swift
//  sabusuku
//
//  Created by hashimo ryoya on 2023/09/05.
//

import SwiftUI

struct ContentView: View {
    static let samplePaymentDates: [Date] = [Date()]

    var body: some View {
        VStack {
            TabView {
                ZStack {
                    SubscriptionListView()
                        .background(Color("Color"))
                }
                .tabItem {
                    Image(systemName: "house")
                        .padding()
                    Text("ホーム")
                        .padding()
                }
                
                ZStack {
                    CalendarView1()
                }
                .tabItem {
                    Image(systemName: "calendar")
                    Text("カレンダー")
                }
                
                SubscriptionGraphView()
                    .tabItem {
                        Image(systemName: "chart.pie")
                        Text("グラフ")
                    }
                SettingsView()
                    .tabItem {
                        Image(systemName: "gearshape.fill")
                        Text("設定")
                    }
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
