import XCTest

final class TypingKidsAppUITests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    func testTypingFlowShowsResults() {
        let app = XCUIApplication()
        app.launchEnvironment["USE_SPEECH_MOCK"] = "1"
        app.launch()

        app.buttons["Escritura"].click()
        app.buttons["typing_start_button"].click()

        let editor = app.textViews["typing_text_editor"]
        editor.click()
        editor.typeText("El gato Tomás encontró una caja pequeña.")

        app.buttons["typing_finish_button"].click()
        XCTAssertTrue(app.staticTexts["typing_results_label"].waitForExistence(timeout: 2))
    }

    func testReadingFlowShowsResults() {
        let app = XCUIApplication()
        app.launchEnvironment["USE_SPEECH_MOCK"] = "1"
        app.launch()

        app.buttons["Lectura"].click()
        app.buttons["reading_start_button"].click()
        for _ in 0..<50 {
            if app.staticTexts["reading_results_label"].exists { break }
            app.buttons["reading_next_button"].click()
        }
        if !app.staticTexts["reading_results_label"].exists {
            app.buttons["reading_finish_button"].click()
        }
        XCTAssertTrue(app.staticTexts["reading_results_label"].waitForExistence(timeout: 2))
    }
}
