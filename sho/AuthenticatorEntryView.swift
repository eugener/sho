//
//  AuthenticatorEntryView.swift
//  sho
//
//  Created by Eugene Ryzhikov on 4/7/25.
//

import SwiftUICore
import UIKit

struct AuthenticatorEntryView: View {
    let iconName: String
    let serviceName: String
    let userId: String
    let code: String
    let timeRemaining: Int
    @State private var showCopied = false

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                // Icon
//                Image(systemName: iconName)
//                    .resizable()
//                    .scaledToFit()
//                    .frame(width: 30, height: 30)
//                    .foregroundStyle(.blue)
//                    .background(Circle().fill(.blue.opacity(0.05)))
                CompanyLogoView(companyName: serviceName, size: 40)

                // Service + User Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(serviceName)
                        .font(.system(size: 16))
                    Text(userId)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                // Code + Time Remaining
                VStack(alignment: .trailing, spacing: 8) {
                    HStack(spacing: 4) {
                        ForEach(formatCode(code), id: \.self) { part in
                            Text(part)
                                .kerning(-1)
//                                .tracking(-1.5)
                                .font(.system(.title, design: .monospaced))
                                .foregroundColor(.blue)
//                                .bold()
                        }
                    }

                    Text("\(timeRemaining)s")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal)
            
            .onTapGesture {
                UIPasteboard.general.string = code.replacingOccurrences(of: " ", with: "")
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
                withAnimation {
                    showCopied = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation {
                        showCopied = false
                    }
                }
            }

            // Custom Divider
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(.gray.opacity(0.3))
        }
        .overlay(
            ToastView(message: "Code Copied", isShowing: $showCopied)
        )
    }
    
    private func formatCode(_ code: String) -> [String] {
        if code.count > 3 {
            return [String(code.prefix(3)), String(code.dropFirst(3))]
        } else {
            return [code]
        }
    }
}

struct ToastView: View {
    let message: String
    @Binding var isShowing: Bool
    
    var body: some View {
        VStack {
            Spacer()
            
            if isShowing {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.white)
                    
                    Text(message)
                        .font(.subheadline)
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(Color.green.opacity(0.9))
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .padding(.bottom, 20)
            }
        }
    }
}
