import XCTest
import Nimble

class Tests: BaseTestCase {

    func testTrending() {

        start()
            .waitForFirstResponse(WaitLimit.long)
            .scrollDown(nTimes: 4)
            .contentLoadingShouldComplete(WaitLimit.long)
            .contentIsFine()
    }


}
