import XCTest

class PerfomanceTests: XCTestCase {

    // ReadMore: https://useyourloaf.com/blog/testing-app-launch-time/

    func testMemoryUsage() {

        XCTContext.info("Тест скролит ленту и мониторит чтобы память не утекала")
        XCUIApplication().launch()

        self.measure(metrics: [XCTMemoryMetric()]) {
            MainScreen()
                .waitForFirstResponse(WaitLimit.long)
                .scrollDown(nTimes: 3)
        }
    }

    func testLaunchPerformance() {

        XCTContext.info("Тест проверяет сколько секунд нужно приложению чтобы запуститься")

        self.measure(metrics: [XCTClockMetric()]) {
            XCUIApplication().launch()
        }
    }
}
