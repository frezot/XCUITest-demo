import XCTest

class BaseTestCase: XCTestCase {

    override func setUp() {
        super.setUp()
        continueAfterFailure = true
        let app = XCUIApplication()
        app.launch()
    }

    func start() -> MainScreen {
        return XCTContext.step("Ждем сплэш") {
            return MainScreen()
        }
    }

    override func tearDown() {
        if (testRun?.failureCount ?? 0) > 0 {
            takeScreenShot()
        }
        super.tearDown()
    }

}
