import XCTest
import Nimble

class Tests: BaseTestCase {

    func testTrending() {

        start()
            .screenHeaderIs("GIPHY")
            .waitForFirstResponse(WaitLimit.long)
            .scrollDown(nTimes: 4)
            .contentLoadingShouldComplete(WaitLimit.long)
            .contentIsFine()
            .scrollToTopShouldWorks()
    }

    func testSearcWithoutResults() {

        start()
            .checkSearchBar(placeholder: "Search gif")
            .search(for: "*")
            .searchResultIsEmpty(failText: "No gifs")
            .clearSearchBar()
    }

}
