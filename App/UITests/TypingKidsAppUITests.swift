import XCTest

final class TypingKidsAppUITests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    func testTypingFlowShowsResults() {
        let app = launchApp()
        createUser(app: app, name: "Tutor", role: "Tutor")

        app.buttons["Escritura"].click()
        app.buttons["typing_start_button"].click()

        let editor = app.textViews["typing_text_editor"]
        editor.click()
        editor.typeText("El gato Tomás encontró una caja pequeña.")

        app.buttons["typing_finish_button"].click()
        XCTAssertTrue(app.staticTexts["typing_results_label"].waitForExistence(timeout: 2))
    }

    func testReadingFlowShowsResults() {
        let app = launchApp()
        createUser(app: app, name: "Tutor", role: "Tutor")

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

    func testTutorSeesStoriesTab() {
        let app = launchApp()
        createUser(app: app, name: "Tutor", role: "Tutor")

        XCTAssertTrue(app.buttons["Historias"].waitForExistence(timeout: 2))
    }

    func testAlumnoDoesNotSeeStoriesTab() {
        let app = launchApp()
        createUser(app: app, name: "Alumno", role: "Alumno")

        XCTAssertFalse(app.buttons["Historias"].exists)
    }

    func testVocabularyTabShowsWord() {
        let app = launchApp()
        createUser(app: app, name: "Tutor", role: "Tutor")

        app.buttons["Vocabulario"].click()
        XCTAssertTrue(app.otherElements["word_learning_view"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["word_learning_word_label"].waitForExistence(timeout: 2))
    }

    private func launchApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchEnvironment["USE_SPEECH_MOCK"] = "1"
        app.launchEnvironment["USE_IN_MEMORY_STORE"] = "1"
        app.launchEnvironment["USE_CLIPART_MOCK"] = "1"
        app.terminate()
        app.launch()
        return app
    }

    private func createUser(app: XCUIApplication, name: String, role: String) {
        if !app.buttons["create_user_button"].waitForExistence(timeout: 2) {
            forceLogoutIfNeeded(app: app)
        }

        app.buttons["create_user_button"].click()

        let nameField = app.textFields["create_user_name_field"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 2))
        nameField.click()
        nameField.typeText(name)

        app.buttons[role].click()

        let pinField = app.secureTextFields["create_user_pin_field"]
        pinField.click()
        pinField.typeText("1234")

        app.buttons["create_user_submit_button"].click()
        XCTAssertTrue(app.otherElements["main_tab_view"].waitForExistence(timeout: 2))
    }

    private func forceLogoutIfNeeded(app: XCUIApplication) {
        let profileMenu = app.buttons["profile_menu_button"]
        if profileMenu.waitForExistence(timeout: 2) {
            profileMenu.click()
            let logout = app.buttons["profile_logout_button"]
            if logout.waitForExistence(timeout: 2) {
                logout.click()
            }
        }
        _ = app.buttons["create_user_button"].waitForExistence(timeout: 2)
    }
}
