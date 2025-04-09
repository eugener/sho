//
//  ContentView.swift
//  sho
//
//  Created by Eugene Ryzhikov on 4/6/25.
//

import SwiftUI

var codeEntryList = [
    CodeEntry(name: "AWS", userId: "steve@example.com", secret: "JBSWY3DXEHPK3PXP"),
    CodeEntry(name: "GitHub", userId: "steve@example.com", secret: "JBSWY3DPEHPK3PXP"),
    CodeEntry(name: "EzWare", userId: "steve@xxx.com", secret: "JBSWY3DPCSPK3PXP"),
]

struct ContentView: View {
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(codeEntryList.indices, id: \.self) { i in
                    let entry = codeEntryList[i]
                    AuthenticatorEntryView(
                        iconName: "globe",
                        serviceName: entry.serviceName,
                        userId: entry.userName,
                        code: entry.generateCode(),
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
