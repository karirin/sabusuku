//
//  SettingView.swift
//  Goal
//
//  Created by hashimo ryoya on 2023/06/10.
//

import SwiftUI
import WebKit

struct SettingsView: View {
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("情報")) {
                    NavigationLink(destination: TermsOfServiceView()) {
                        HStack {
                            Text("利用規約")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(Color(.systemGray4))
                        }
                    }
                    
                    NavigationLink(destination: PrivacyView()) {
                        HStack {
                            Text("プライバシーポリシー")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(Color(.systemGray4))
                        }
                    }
                    
                    NavigationLink(destination: WebView(urlString: "https://docs.google.com/forms/d/e/1FAIpQLSfHxhubkEjUw_gexZtQGU8ujZROUgBkBcIhB3R6b8KZpKtOEQ/viewform?embedded=true")) {
                        HStack {
                            Text("お問い合せ")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(Color(.systemGray4))
                        }
                    }
                }
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle("設定")
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct WebView: UIViewRepresentable {
    let urlString: String

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            uiView.load(request)
        }
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView

        init(_ parent: WebView) {
            self.parent = parent
        }
    }
}



struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

