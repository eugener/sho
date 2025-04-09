import SwiftUI

// TODO : Cache logos
struct CompanyLogoView: View {
    let companyName: String
    let size: CGFloat

    private var logoURL: URL? {
        let domain = companyName + ".com"
        return URL(string: "https://logo.clearbit.com/\(domain)")
    }
    
    private var fallbackLetter: String {
           String(companyName.prefix(1)).uppercased()
   }

    var body: some View {
        Group {
            if let url = logoURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                    case .failure(_), .empty:
                        fallbackCircle
                    @unknown default:
                        fallbackCircle
                    }
                }
            } else {
                fallbackCircle
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }
    
    private var fallbackCircle: some View {
            Circle()
                .fill(Color.black.opacity(0.7))
                .overlay(
                    Text(fallbackLetter)
                        .font(.headline)
                        .foregroundColor(.white)
                )
        }
}

