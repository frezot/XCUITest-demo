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

    func testSearchWithoutResults() {

        start()
            .checkSearchBar(placeholder: "Search gif")
            .search(for: "*")
            .searchResultIsEmpty(failText: "No gifs")
            .clearSearchBar()
    }

    func testSearchWithResults() {

        start()
            .checkSearching(request: "独裁者", result: "l3XEYNJTJyC7m")
            .checkSearching(request: "Albus", result: "TyM0y7hjIHcRO")
    }

}
