import XCTest

final class HabetUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testMainTabsLaunchAndNavigate() throws {
        let app = XCUIApplication()
        app.launchEnvironment["UI_TESTING"] = "1"
        app.launch()

        XCTAssertTrue(app.navigationBars["Habet"].waitForExistence(timeout: 10))

        app.tabBars.buttons["ベット"].tap()
        XCTAssertTrue(app.navigationBars["ベット設定"].waitForExistence(timeout: 5))

        app.tabBars.buttons["カジノ"].tap()
        XCTAssertTrue(app.navigationBars["カジノ"].waitForExistence(timeout: 5))

        app.tabBars.buttons["ショップ"].tap()
        XCTAssertTrue(app.navigationBars["ショップ"].waitForExistence(timeout: 5))

        app.tabBars.buttons["プロフ"].tap()
        XCTAssertTrue(app.navigationBars["プロフィール"].waitForExistence(timeout: 5))

        app.tabBars.buttons["ホーム"].tap()
        XCTAssertTrue(app.navigationBars["Habet"].waitForExistence(timeout: 5))
    }

    func testBetSetupPresetApplies() throws {
        let app = XCUIApplication()
        app.launchEnvironment["UI_TESTING"] = "1"
        app.launch()

        app.tabBars.buttons["ベット"].tap()
        XCTAssertTrue(app.navigationBars["ベット設定"].waitForExistence(timeout: 5))

        let presetButton = app.buttons["読書 30分"]
        XCTAssertTrue(presetButton.waitForExistence(timeout: 5))
        presetButton.tap()

        let textFields = app.textFields
        XCTAssertTrue(textFields.element(boundBy: 0).waitForExistence(timeout: 5))
        XCTAssertEqual(textFields.element(boundBy: 0).value as? String, "集中して本を30分間読む")
    }
}
