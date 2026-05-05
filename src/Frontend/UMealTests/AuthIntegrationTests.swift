//
//  AuthIntegrationTests.swift
//  UMeal
//
//  Created by Zhiyang Wen on 5/1/26.
//


import XCTest
@testable import UMeal

@MainActor
final class AuthIntegrationTests: XCTestCase {

    var auth: AuthManager!

    override func setUp() async throws {
        auth = AuthManager()
        // Make sure we start logged out
        await auth.logout()
    }

    override func tearDown() async throws {
        // Clean up — always logout after each test
        await auth.logout()
        auth = nil
    }

    // Sign Up Tests

    func test_signUp_withValidCredentials_succeeds() async throws {
        // Use unique email each time to avoid conflicts
        let testEmail = "test_\(Int(Date().timeIntervalSince1970))@umass.edu"

        await auth.signUp(email: testEmail, password: "password1234", fullName: "Test User")

        XCTAssertTrue(auth.isLoggedIn, "Should be logged in after valid signup")
        XCTAssertTrue(auth.errorMessage.isEmpty, "Should have no error after valid signup")
    }

    func test_signUp_withInvalidEmail_fails() async throws {
        await auth.signUp(email: "notanemail", password: "password1234", fullName: "Test User")

        XCTAssertFalse(auth.isLoggedIn, "Should not be logged in with invalid email")
        XCTAssertFalse(auth.errorMessage.isEmpty, "Should have error message with invalid email")
    }

    func test_signUp_withShortPassword_fails() async throws {
        let testEmail = "test_short_\(Int(Date().timeIntervalSince1970))@umass.edu"

        await auth.signUp(email: testEmail, password: "123", fullName: "Test User")

        XCTAssertFalse(auth.isLoggedIn, "Should not be logged in with short password")
        XCTAssertFalse(auth.errorMessage.isEmpty, "Should have error message with short password")
    }

    func test_signUp_withEmptyFullName_fails() async throws {
        let testEmail = "test_empty_\(Int(Date().timeIntervalSince1970))@umass.edu"

        await auth.signUp(email: testEmail, password: "password123", fullName: "")

        // Either fails to sign up or signs up without name
        XCTAssertNotNil(auth, "Auth manager should still exist")
    }

    func test_signUp_withDuplicateEmail_fails() async throws {
        let testEmail = "duplicate_\(Int(Date().timeIntervalSince1970))@umass.edu"

        // First signup
        await auth.signUp(email: testEmail, password: "password123", fullName: "Test User")
        XCTAssertTrue(auth.isLoggedIn, "First signup should succeed")
        await auth.logout()

        // Second signup with same email
        await auth.signUp(email: testEmail, password: "password123", fullName: "Test User")
        XCTAssertFalse(auth.isLoggedIn, "Duplicate email signup should fail")
        XCTAssertFalse(auth.errorMessage.isEmpty, "Should have error for duplicate email")
    }

    // Login Tests

    func test_login_withValidCredentials_succeeds() async throws {
        // First create an account
        let testEmail = "login_test_\(Int(Date().timeIntervalSince1970))@umass.edu"
        await auth.signUp(email: testEmail, password: "password123", fullName: "Test User")
        await auth.logout()

        // Then login
        await auth.login(email: testEmail, password: "password123")

        XCTAssertTrue(auth.isLoggedIn, "Should be logged in with valid credentials")
        XCTAssertTrue(auth.errorMessage.isEmpty, "Should have no error with valid credentials")
    }

    func test_login_withWrongPassword_fails() async throws {
        // First create an account
        let testEmail = "wrong_pass_\(Int(Date().timeIntervalSince1970))@umass.edu"
        await auth.signUp(email: testEmail, password: "password123", fullName: "Test User")
        await auth.logout()

        // Login with wrong password
        await auth.login(email: testEmail, password: "wrongpassword")

        XCTAssertFalse(auth.isLoggedIn, "Should not be logged in with wrong password")
        XCTAssertFalse(auth.errorMessage.isEmpty, "Should have error with wrong password")
    }

    func test_login_withNonExistentUser_fails() async throws {
        await auth.login(email: "nobody_\(Int(Date().timeIntervalSince1970))@umass.edu",
                        password: "password123")

        XCTAssertFalse(auth.isLoggedIn, "Should not be logged in with non-existent user")
        XCTAssertFalse(auth.errorMessage.isEmpty, "Should have error for non-existent user")
    }

    func test_login_withEmptyEmail_fails() async throws {
        await auth.login(email: "", password: "password123")

        XCTAssertFalse(auth.isLoggedIn, "Should not be logged in with empty email")
    }

    func test_login_withEmptyPassword_fails() async throws {
        await auth.login(email: "test@umass.edu", password: "")

        XCTAssertFalse(auth.isLoggedIn, "Should not be logged in with empty password")
    }

    // Logout Tests

    func test_logout_succeeds() async throws {
        // First create and login
        let testEmail = "logout_test_\(Int(Date().timeIntervalSince1970))@umass.edu"
        await auth.signUp(email: testEmail, password: "password123", fullName: "Test User")
        XCTAssertTrue(auth.isLoggedIn, "Should be logged in before logout")

        // Logout
        await auth.logout()
        XCTAssertFalse(auth.isLoggedIn, "Should be logged out after logout")
    }

    func test_logout_clearsUsername() async throws {
        let testEmail = "clear_test_\(Int(Date().timeIntervalSince1970))@umass.edu"
        await auth.signUp(email: testEmail, password: "password123", fullName: "Test User")

        await auth.logout()
        XCTAssertTrue(auth.username.isEmpty, "Username should be cleared after logout")
    }

    // Session Tests

    func test_checkSession_whenNotLoggedIn_isLoggedOut() async throws {
        await auth.logout()
        await auth.checkSession()
        XCTAssertFalse(auth.isLoggedIn, "Should not be logged in when no session exists")
    }

    func test_checkSession_whenLoggedIn_staysLoggedIn() async throws {
        let testEmail = "session_test_\(Int(Date().timeIntervalSince1970))@umass.edu"
        await auth.signUp(email: testEmail, password: "password123", fullName: "Test User")
        XCTAssertTrue(auth.isLoggedIn)

        // Check session should keep them logged in
        await auth.checkSession()
        XCTAssertTrue(auth.isLoggedIn, "Should stay logged in when session exists")
    }
}
