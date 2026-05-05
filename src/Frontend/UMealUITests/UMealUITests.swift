//
//  UMealUITests.swift
//  UMealUITests
//
//  Created by Zhiyang Wen on 5/1/26.
//

import XCTest

final class UMealUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI_TESTING"]
        app.launch()

        // Wait for landing page to be ready (UI_TESTING bypasses login)
        XCTAssertTrue(
            app.staticTexts["UMeal"].waitForExistence(timeout: 10),
            "Landing page should load after launch"
        )
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // Helpers

    @discardableResult
    private func goToProfile() -> Bool {
        let profileButton = app.buttons["profileButton"]
        guard profileButton.waitForExistence(timeout: 5) else {
            XCTFail("profileButton not found on landing page")
            return false
        }
        profileButton.tap()
        let loaded = app.staticTexts["Nutrition Goals"].waitForExistence(timeout: 5)
        XCTAssertTrue(loaded, "Profile page should load after tapping profileButton")
        return loaded
    }

    // Landing Page Tests

    func test_landingPage_elementsExist() {
        XCTAssertTrue(app.staticTexts["Today's Recommendations"].waitForExistence(timeout: 5),
                      "Today's Recommendations should be visible")
        XCTAssertTrue(app.buttons["filter_All"].waitForExistence(timeout: 5),
                      "All filter should exist")
        XCTAssertTrue(app.buttons["filter_High Protein"].exists,
                      "High Protein filter should exist")
        XCTAssertTrue(app.buttons["filter_Vegetarian"].exists,
                      "Vegetarian filter should exist")
        XCTAssertTrue(app.buttons["filter_Halal"].exists,
                      "Halal filter should exist")
        XCTAssertTrue(app.buttons["filter_Low Calorie"].exists,
                      "Low Calorie filter should exist")
    }

    func test_landingPage_filterAll_isSelectedByDefault() {
        let allFilter = app.buttons["filter_All"]
        XCTAssertTrue(allFilter.waitForExistence(timeout: 5), "All filter should exist by default")
    }

    func test_landingPage_filterButtons_areAllTappable() {
        let filterNames = ["filter_High Protein", "filter_Vegetarian",
                           "filter_Halal", "filter_Low Calorie", "filter_All"]
        for filterName in filterNames {
            let filter = app.buttons[filterName]
            XCTAssertTrue(filter.waitForExistence(timeout: 5), "\(filterName) should exist")
            filter.tap()
        }
    }

    func test_landingPage_navigatesToProfile() {
        let profileButton = app.buttons["profileButton"]
        XCTAssertTrue(profileButton.waitForExistence(timeout: 5), "Profile button should exist")
        profileButton.tap()
        XCTAssertTrue(app.staticTexts["Nutrition Goals"].waitForExistence(timeout: 5),
                      "Should navigate to profile page and show Nutrition Goals")
    }

    func test_landingPage_diningHallsVisible() {
        XCTAssertTrue(app.staticTexts["Dining Halls"].waitForExistence(timeout: 5),
                      "Dining Halls section should be visible")
    }

    func test_landingPage_exploreMoreVisible() {
        app.swipeUp()
        XCTAssertTrue(app.staticTexts["Explore More"].waitForExistence(timeout: 5),
                      "Explore More section should be visible after scrolling")
    }

    // Profile Page Tests

    func test_profilePage_elementsExist() {
        guard goToProfile() else { return }

        XCTAssertTrue(app.staticTexts["Nutrition Goals"].exists,
                      "Nutrition Goals should exist")
        XCTAssertTrue(app.staticTexts["Dietary Restrictions"].exists,
                      "Dietary Restrictions should exist")
        XCTAssertTrue(app.staticTexts["Notifications"].exists,
                      "Notifications should exist")
        XCTAssertTrue(app.buttons["saveChangesButton"].waitForExistence(timeout: 3),
                      "Save Changes button should exist")
        XCTAssertTrue(app.buttons["addRestrictionButton"].waitForExistence(timeout: 3),
                      "Add Restriction button should exist")
    }

    func test_profilePage_editCalories_validInput_saves() {
        guard goToProfile() else { return }

        app.buttons["editDailyCaloriesButton"].tap()

        let textField = app.alerts.textFields.firstMatch
        XCTAssertTrue(textField.waitForExistence(timeout: 3), "Alert text field should appear")
        textField.clearAndTypeText("2000")
        app.alerts.buttons["Save"].tap()

        XCTAssertTrue(app.staticTexts["2000 kcal"].waitForExistence(timeout: 3),
                      "Updated calorie value should be visible")
    }

    func test_profilePage_editCalories_zeroInput_showsError() {
        guard goToProfile() else { return }

        app.buttons["editDailyCaloriesButton"].tap()

        let textField = app.alerts.textFields.firstMatch
        XCTAssertTrue(textField.waitForExistence(timeout: 3), "Alert text field should appear")
        textField.clearAndTypeText("0")
        app.alerts.buttons["Save"].tap()

        XCTAssertTrue(app.alerts["Invalid Input"].waitForExistence(timeout: 3),
                      "Invalid input alert should appear for zero calories")
        app.alerts.buttons["Cancel"].tap()
    }

    func test_profilePage_editProtein_validInput_saves() {
        guard goToProfile() else { return }

        app.buttons["editProteinTargetButton"].tap()

        let textField = app.alerts.textFields.firstMatch
        XCTAssertTrue(textField.waitForExistence(timeout: 3), "Alert text field should appear")
        textField.clearAndTypeText("150")
        app.alerts.buttons["Save"].tap()

        XCTAssertTrue(app.staticTexts["150 g"].waitForExistence(timeout: 3),
                      "Updated protein value should be visible")
    }

    func test_profilePage_editProtein_negativeInput_showsError() {
        guard goToProfile() else { return }

        app.buttons["editProteinTargetButton"].tap()

        let textField = app.alerts.textFields.firstMatch
        XCTAssertTrue(textField.waitForExistence(timeout: 3), "Alert text field should appear")
        textField.clearAndTypeText("-10")
        app.alerts.buttons["Save"].tap()

        XCTAssertTrue(app.alerts["Invalid Input"].waitForExistence(timeout: 3),
                      "Invalid input alert should appear for negative protein")
        app.alerts.buttons["Cancel"].tap()
    }

    func test_profilePage_addRestriction_appearsInList() {
        guard goToProfile() else { return }

        app.swipeUp()

        let addButton = app.buttons["addRestrictionButton"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 3), "Add Restriction button should exist")
        addButton.tap()

        let textField = app.alerts.textFields.firstMatch
        XCTAssertTrue(textField.waitForExistence(timeout: 3), "Alert text field should appear")
        textField.typeText("Gluten Free")
        app.alerts.buttons["Add"].tap()

        XCTAssertTrue(app.staticTexts["Gluten Free"].waitForExistence(timeout: 3),
                      "New restriction should appear in list")
    }

    func test_profilePage_addRestriction_emptyInput_doesNotAdd() {
        guard goToProfile() else { return }

        app.swipeUp()

        let addButton = app.buttons["addRestrictionButton"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 3), "Add Restriction button should exist")
        addButton.tap()

        // Tap Add without typing anything
        app.alerts.buttons["Add"].tap()

        XCTAssertTrue(app.staticTexts["Dietary Restrictions"].waitForExistence(timeout: 3),
                      "Should still be on profile page with no new empty restriction")
    }

    func test_profilePage_saveChanges_showsSuccessMessage() {
        guard goToProfile() else { return }

        app.swipeUp()

        let saveButton = app.buttons["saveChangesButton"]
        XCTAssertTrue(saveButton.waitForExistence(timeout: 3), "Save Changes button should exist")
        saveButton.tap()

        XCTAssertTrue(app.staticTexts["Changes saved successfully!"].waitForExistence(timeout: 3),
                      "Success message should appear after saving")
    }

    func test_profilePage_backButton_returnsToLanding() {
        guard goToProfile() else { return }

        // Scroll to top to ensure back button is hittable
        app.scrollViews.firstMatch.swipeDown()

        let backButton = app.buttons["backButton"]
        XCTAssertTrue(backButton.waitForExistence(timeout: 3), "Back button should exist")
        backButton.tap()

        XCTAssertTrue(app.staticTexts["Today's Recommendations"].waitForExistence(timeout: 5),
                      "Should return to landing page")
    }

    func test_profilePage_toggleNotifications() {
        guard goToProfile() else { return }

        app.swipeUp()

        let toggle = app.switches["newMenuAlertsToggle"]
        XCTAssertTrue(toggle.waitForExistence(timeout: 3), "Notifications toggle should exist")

        let valueBefore = toggle.value as? String
        toggle.tap()
        let valueAfter = toggle.value as? String

        XCTAssertNotEqual(valueBefore, valueAfter, "Toggle value should change after tapping")
    }
}

// XCUIElement Helper

extension XCUIElement {
    /// Selects all existing text in the field and replaces it with the given string.
    func clearAndTypeText(_ text: String) {
        self.tap()

        // Use triple-tap to select all text (works reliably on number fields)
        self.tap(withNumberOfTaps: 3, numberOfTouches: 1)

        // Fallback: try Select All from menu
        let selectAll = XCUIApplication().menuItems["Select All"]
        if selectAll.waitForExistence(timeout: 1) {
            selectAll.tap()
        }

        self.typeText(XCUIKeyboardKey.delete.rawValue)
        self.typeText(text)
    }
}
