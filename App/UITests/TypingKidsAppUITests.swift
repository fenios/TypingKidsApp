import XCTest

final class TypingKidsAppUITests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    func testTypingFlowShowsResults() {
        let app = XCUIApplication()
        app.launch()

        app.buttons["Escritura"].click()
        app.buttons["typing_start_button"].click()

        let editor = app.textViews["typing_text_editor"]
        editor.click()
        editor.typeText("El gato Tomás encontró una caja pequeña.")

        app.buttons["typing_finish_button"].click()
        XCTAssertTrue(app.otherElements["typing_results"].exists)
    }

    func testReadingFlowShowsResults() {
        let app = XCUIApplication()
        app.launch()

        app.buttons["Lectura"].click()
        app.buttons["reading_start_button"].click()
        app.buttons["reading_next_button"].click()
        app.buttons["reading_next_button"].click()
        app.buttons["reading_next_button"].click()

        XCTAssertTrue(app.otherElements["reading_results"].exists)
    }
}
