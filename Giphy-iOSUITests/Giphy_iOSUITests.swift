import XCTest
import Nimble

class Giphy_iOSUITests: XCTestCase {

    let app = XCUIApplication()

    override func setUp() {
        continueAfterFailure = false
        app.launch()
    }

    override func tearDown() {

    }

    func testExample() {
        //TODO: implement
        sleep(5)
        print(app.debugDescription)
    }

}
