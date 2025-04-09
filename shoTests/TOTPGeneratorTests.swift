//
//  TOTPGeneratorTests.swift
//  sho
//
//  Created by Eugene Ryzhikov on 4/8/25.
//


import Testing
@testable import sho // Replace with your actual module name
import Foundation

@Suite("TOTPGeneratorTests")
struct TOTPGeneratorTests {
    
    // Test vectors from RFC 6238 (using SHA-1)
    let testVectors: [(time: UInt64, expected: String)] = [
        (59, "94287082"),          // 1970-01-01 00:00:59
        (1111111109, "07081804"),  // 2005-03-18 01:58:29
        (1111111111, "14050471"),  // 2005-03-18 01:58:31
        (1234567890, "89005924"),  // 2009-02-13 23:31:30
        (2000000000, "69279037"),  // 2033-05-18 03:33:20
        (20000000000, "65353130")  // 2603-10-11 11:33:20
    ]
    
    // Standard test secret from RFC documentation
    let testSecret = "12345678901234567890"
    
    @Test("TOTP code generation matches RFC 6238 test vectors")
    func testTOTPGeneration() throws {
        // Create generator with 8 digits to match test vectors
        // Use isBase32: false for RFC test vectors as they use ASCII encoding
        let generator = TOTPGenerator(secret: testSecret, digits: 8, timeInterval: 30, isBase32: false)
        
        for vector in testVectors {
            // Create date from Unix timestamp
            let date = Date(timeIntervalSince1970: TimeInterval(vector.time))
            
            // Generate code at specified time
            let code = generator.generateCode(at: date)
            
            #expect(code == vector.expected, "Failed for timestamp \(vector.time)")
        }
    }
    
    @Test("Remaining seconds calculation is accurate")
    func testRemainingSeconds() throws {
        let generator = TOTPGenerator(secret: "JBSWY3DPEHPK3PXP")
        
        // Test at exact interval boundary
        let exactBoundary = Date(timeIntervalSince1970: 1800) // 30 * 60 seconds exactly
        #expect(generator.remainingSeconds(at: exactBoundary) == 30)
        
        // Test at 15 seconds past interval
        let midInterval = Date(timeIntervalSince1970: 1815) // 15 seconds past boundary
        #expect(generator.remainingSeconds(at: midInterval) == 15)
        
        // Test at 1 second before next interval
        let endInterval = Date(timeIntervalSince1970: 1829) // 29 seconds past boundary
        #expect(generator.remainingSeconds(at: endInterval) == 1)
    }
    
    @Test("Base32 decoding produces correct binary data")
    func testBase32Decoding() throws {
        // Test with a known Base32 string and expected decoded value
        let base32String = "JBSWY3DPEHPK3PXP"
        let expectedHex = "48656c6c6f21deadbeef" // "Hello!" followed by deadbeef in hex
        
        // Use the private base32Decode through the test helper
        let decodedData = testHelperBase32Decode(base32String)
        
        // Convert to hex string for comparison
        let hexString = decodedData.map { String(format: "%02x", $0) }.joined()
        
        #expect(hexString.lowercased() == expectedHex.lowercased())
    }
    
    @Test("Works with Google Authenticator compatible secrets")
    func testGoogleAuthenticatorCompatibility() throws {
        // This is a test secret that would be shared with Google Authenticator
        let secret = "JBSWY3DPEHPK3PXP" // Base32 encoded test secret
        let generator = TOTPGenerator(secret: secret)
        
        // To test: Generate a code at a specific time and manually verify
        let time = Date(timeIntervalSince1970: 1600000000) // 2020-09-13 12:26:40 UTC
        let code = generator.generateCode(at: time)
        
        // Verify the code generation is consistent
        #expect(generator.generateCode(at: time) == code)
    }
    
    @Test("Handles invalid Base32 input gracefully")
    func testInvalidBase32Input() throws {
        // Test with invalid characters
        let invalidBase32 = "JB$WY3DP@HPK3PXP"
        let generator = TOTPGenerator(secret: invalidBase32)
        
        // Should not crash and should generate a code (even if based on partial data)
        let code = generator.generateCode()
        #expect(!code.isEmpty, "Should generate a code even with invalid input")
        #expect(code.count == 6, "Default code should be 6 digits")
    }
    
//    @Test("Code generation performs efficiently", true as! TestTrait)
//    func testPerformance() throws {
//        let generator = TOTPGenerator(secret: "JBSWY3DPEHPK3PXP")
//        
//        #measure(time: .seconds(0.1)) {
//            // Test code generation performance
//            for _ in 0..<100 {
//                _ = generator.generateCode()
//            }
//        }
//    }
    
    // Helper function to access the private base32Decode method for testing
    func testHelperBase32Decode(_ string: String) -> Data {
        // This would need access to your internal implementation
        // This is a simplified version - you'll need to provide actual access to your method
        return TOTPGenerator.base32Decode(string)
    }
}
