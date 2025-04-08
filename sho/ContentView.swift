//
//  ContentView.swift
//  sho
//
//  Created by Eugene Ryzhikov on 4/6/25.
//

import SwiftUI

var codeEntryList = [
    CodeEntry(name: "AWS", userId: "steve@example.com", code: "123 456"),
    CodeEntry(name: "GitHub", userId: "steve@example.com", code: "987 654"),
    CodeEntry(name: "EzWare", userId: "steve@xxx.com", code: "987 654"),
]

struct ContentView: View {
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(codeEntryList.indices, id: \.self) { i in
                    let entry = codeEntryList[i]
                    AuthenticatorEntryView(
                        iconName: "globe",
                        serviceName: entry.name,
                        userId: entry.userId,
                        code: entry.code,
                        timeRemaining: 23 // or dynamic value
                    )
                }
            }
        }

    }

}


#Preview {
    ContentView()
}
