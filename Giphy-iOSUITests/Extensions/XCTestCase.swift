import XCTest

extension XCTestCase {

    func takeScreenShot(name screenshotName: String? = nil)
    {
        let screenshot = XCUIScreen.main.screenshot()
        let attach = XCTAttachment(screenshot: screenshot, quality: .original)
        attach.name = screenshotName ?? name + "_" + String(NSDate().timeIntervalSince1970)
        attach.lifetime = .keepAlways
        add(attach)
    }
}
