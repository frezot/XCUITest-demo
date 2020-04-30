import XCTest
import Nimble

class AbstractScreen {

    typealias Completion = (() -> Void)?
    let log = Logger().log

    required init(timeout: TimeInterval = WaitLimit.long, completion: Completion = nil) {
        log("waiting \(timeout)s for \(String(describing: self)) existence")

        expect(self.rootElement.waitForExistence(timeout: timeout)).to(beTrue(), description: "Page \(String(describing: self)) waited, but not loaded")
        completion?()
    }

    var rootElement: XCUIElement {
        fatalError("rootElement всегда определяется наследником, по сути это элемент-маркер по которому мы понимаем что находимся где и должны")
    }

}
