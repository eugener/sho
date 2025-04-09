import Foundation
import CryptoKit

class TOTPGenerator {
    private let secretKey: Data
    private let digits: Int
    private let timeInterval: TimeInterval
    
    // Static constant for the Base32 character set
    private static let base32Chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567"
    
    init(secret: String, digits: Int = 6, timeInterval: TimeInterval = 30, isBase32: Bool = true) {
        // Convert secret to Data based on the input format
        if isBase32 {
            self.secretKey = TOTPGenerator.base32Decode(secret)
        } else {
            // For RFC test vectors, use ASCII encoding directly
            self.secretKey = secret.data(using: .ascii) ?? Data()
        }
        self.digits = digits
        self.timeInterval = timeInterval
    }
    
    func generateCode(at date: Date = Date()) -> String {
        // Get current timestamp and convert to counter value
        let counter = UInt64(date.timeIntervalSince1970 / timeInterval)
        
        // Convert counter to big-endian representation
        var bigEndianCounter = counter.bigEndian
        let counterData = withUnsafeBytes(of: &bigEndianCounter) { Data($0) }
        
        // Generate HMAC using the secret and counter
        let hmac = generateHMAC(counterData)
        
        // Dynamic truncation - fixed to avoid alignment issues
        let offset = Int(hmac[hmac.count - 1] & 0x0f)
        
        // Extract 4 bytes starting at the offset and manually construct the UInt32 value
        let truncatedHash: UInt32 = ((UInt32(hmac[offset]) & 0xff) << 24) |
                        ((UInt32(hmac[offset + 1]) & 0xff) << 16) |
                        ((UInt32(hmac[offset + 2]) & 0xff) << 8) |
                        (UInt32(hmac[offset + 3]) & 0xff)
        
        // Mask the most significant bit
        let maskedHash = truncatedHash & 0x7FFFFFFF
        
        // Modulo to get the specified number of digits
        let modulo = UInt32(pow(10, Double(digits)))
        let code = maskedHash % modulo
        
        // Format code with leading zeros if needed
        return String(format: "%0\(digits)d", code)
    }
    
    private func generateHMAC(_ message: Data) -> Data {
        let key = SymmetricKey(data: secretKey)
        let hmac = HMAC<Insecure.SHA1>.authenticationCode(for: message, using: key)
        return Data(hmac)
    }
    
    func remainingSeconds(at date: Date = Date()) -> TimeInterval {
        let elapsedSeconds = date.timeIntervalSince1970.truncatingRemainder(dividingBy: timeInterval)
        return timeInterval - elapsedSeconds
    }
    
    // Base32 decoding function
    static func base32Decode(_ string: String) -> Data {
        let paddedString = addPaddingIfNeeded(string.uppercased())
        var result = Data()
        var bits = 0
        var value = 0
        
        for char in paddedString {
            // Skip padding characters
            if char == "=" {
                continue
            }
            
            // Check if character is valid
            guard let index = base32Chars.firstIndex(of: char) else {
                continue // Skip invalid characters
            }
            
            let charValue = base32Chars.distance(from: base32Chars.startIndex, to: index)
            value = (value << 5) | charValue
            bits += 5
            
            if bits >= 8 {
                bits -= 8
                result.append(UInt8(value >> bits))
                value &= (1 << bits) - 1
            }
        }
        
        return result
    }
    
    // Helper function to add padding if needed
    private static func addPaddingIfNeeded(_ string: String) -> String {
        let paddingLength = (8 - string.count % 8) % 8
        return string + String(repeating: "=", count: paddingLength)
    }
}
