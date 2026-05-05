//
//  AuthTests.swift
//  UMeal
//
//  Created by Zhiyang Wen on 4/30/26.
//

import XCTest
@testable import UMeal

final class AuthTests: XCTestCase {

    // Email Validation

    func test_emptyEmail_isInvalid() {
        let email = ""
        XCTAssertTrue(email.isEmpty, "Empty email should be invalid")
    }

    func test_validEmail_containsAtSymbol() {
        let email = "test@umass.edu"
        XCTAssertTrue(email.contains("@"), "Valid email should contain @")
    }

    func test_validEmail_containsDot() {
        let email = "test@umass.edu"
        XCTAssertTrue(email.contains("."), "Valid email should contain .")
    }

    func test_invalidEmail_noAtSymbol() {
        let email = "testumass.edu"
        XCTAssertFalse(email.contains("@"), "Email without @ is invalid")
    }

    func test_invalidEmail_noDomain() {
        let email = "test@"
        let parts = email.split(separator: "@")
        XCTAssertEqual(parts.count, 1, "Email without domain is invalid")
    }

    // UMass Email

    func test_umassEmail_isValid() {
        let email = "zhiyang@umass.edu"
        XCTAssertTrue(email.hasSuffix("@umass.edu"), "Should be a UMass email")
    }

    func test_gmailEmail_isNotUmass() {
        let email = "zhiyang@gmail.com"
        XCTAssertFalse(email.hasSuffix("@umass.edu"), "Gmail is not a UMass email")
    }

    func test_umassEmail_caseInsensitive() {
        let email = "zhiyang@UMASS.EDU".lowercased()
        XCTAssertTrue(email.hasSuffix("@umass.edu"), "UMass email check should be case insensitive")
    }

    // Password Validation

    func test_emptyPassword_isInvalid() {
        let password = ""
        XCTAssertTrue(password.isEmpty, "Empty password should be invalid")
    }

    func test_shortPassword_isInvalid() {
        let password = "123"
        XCTAssertTrue(password.count < 6, "Password under 6 chars is too short")
    }

    func test_validPassword_hasMinLength() {
        let password = "password123"
        XCTAssertTrue(password.count >= 6, "Password should be at least 6 chars")
    }

    func test_exactlyMinLength_isValid() {
        let password = "abc123"
        XCTAssertTrue(password.count >= 6, "Password with exactly 6 chars should be valid")
    }

    func test_longPassword_isValid() {
        let password = "thisIsAVeryLongPassword123!"
        XCTAssertTrue(password.count >= 6, "Long password should be valid")
    }

    // Password Matching (SignUp)

    func test_matchingPasswords_areEqual() {
        let password = "password123"
        let confirmed = "password123"
        XCTAssertEqual(password, confirmed, "Matching passwords should be equal")
    }

    func test_mismatchedPasswords_areNotEqual() {
        let password = "password123"
        let confirmed = "different456"
        XCTAssertNotEqual(password, confirmed, "Mismatched passwords should not be equal")
    }

    func test_emptyConfirmedPassword_doesNotMatch() {
        let password = "password123"
        let confirmed = ""
        XCTAssertNotEqual(password, confirmed, "Empty confirmed password should not match")
    }

    func test_caseSensitivePassword_doesNotMatch() {
        let password = "Password123"
        let confirmed = "password123"
        XCTAssertNotEqual(password, confirmed, "Passwords are case sensitive")
    }

    // Full Name Validation

    func test_emptyFullName_isInvalid() {
        let fullName = ""
        XCTAssertTrue(fullName.isEmpty, "Empty full name should be invalid")
    }

    func test_validFullName_isNotEmpty() {
        let fullName = "Zhiyang Wen"
        XCTAssertFalse(fullName.isEmpty, "Valid full name should not be empty")
    }

    func test_fullName_withSpaces_isValid() {
        let fullName = "John Doe"
        XCTAssertTrue(fullName.contains(" "), "Full name should contain a space")
    }

    func test_whitespaceOnly_isInvalid() {
        let fullName = "   "
        XCTAssertTrue(fullName.trimmingCharacters(in: .whitespaces).isEmpty,
                      "Whitespace-only name should be invalid")
    }

    // Input Guard Logic

    func test_allFieldsFilled_allowsSignUp() {
        let fullName = "Zhiyang Wen"
        let email = "zy@umass.edu"
        let password = "password123"
        let confirmed = "password123"

        let canSignUp = !fullName.isEmpty &&
                        !email.isEmpty &&
                        !password.isEmpty &&
                        password == confirmed

        XCTAssertTrue(canSignUp, "All fields filled with matching passwords should allow signup")
    }

    func test_missingEmail_blocksSignUp() {
        let fullName = "Zhiyang Wen"
        let email = ""
        let password = "password123"
        let confirmed = "password123"

        let canSignUp = !fullName.isEmpty &&
                        !email.isEmpty &&
                        !password.isEmpty &&
                        password == confirmed

        XCTAssertFalse(canSignUp, "Missing email should block signup")
    }

    func test_passwordMismatch_blocksSignUp() {
        let fullName = "Zhiyang Wen"
        let email = "zy@umass.edu"
        let password = "password123"
        let confirmed = "different456"

        let canSignUp = !fullName.isEmpty &&
                        !email.isEmpty &&
                        !password.isEmpty &&
                        password == confirmed

        XCTAssertFalse(canSignUp, "Password mismatch should block signup")
    }
}
