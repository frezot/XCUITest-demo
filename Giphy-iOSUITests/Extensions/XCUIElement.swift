import XCTest
import Nimble

extension XCUIElement {

    internal func writeText(_ text: String) {
        expect(self.waitForExistence(timeout: 3)).to(beTrue(), description: "Поле ввода [\(self.identifier)] не найдено")
        self.tap()
        self.typeText(text)
        guard let typedText = self.value as? String else {
            fail("Что-то пошло не так: в текстовом поле не String value")
            return
        }
        expect(typedText).to(equal(text))
    }

    @discardableResult
    internal func clear() -> XCUIElement {
        guard let text = self.value as? String else {
            fail("Что-то пошло не так: в текстовом поле не String value")
            return self
        }
        let deleteSymbols = text.map { _ in XCUIKeyboardKey.delete.rawValue }
        if deleteSymbols.isEmpty {
            return self
        }
        let stringForRemoveAllSymbols = deleteSymbols.joined(separator: "")
        self.tap()
        self.typeText(stringForRemoveAllSymbols)
        return self
    }

    // @objc нужен для NSPredicate
    @objc public var visible: Bool {
        return self.isVisibleOn(app: XCUIApplication())
    }

    public func isVisibleOn(app: XCUIApplication) -> Bool {
        if self.exists {
            let isObservable = self.exists
                && app.windows.element(boundBy: 0).frame.contains(self.frame)

            let isContentfull = self.exists
                && false == self.frame.isEmpty

            return isObservable && isContentfull
            // может показаться странным дергать exists аж трижды но вызовы методов не молниеносные и элемент может исчезнуть в процесе вычисления, были случаи
        } else {
            return false
        }
    }


    private func waitFor(condition conditionString: String, _ timeLimit: TimeInterval) -> Bool {
        let condition = NSPredicate(format: conditionString)
        let expectation = XCTNSPredicateExpectation(predicate: condition, object: self)
        let result = XCTWaiter().wait(for: [expectation], timeout: timeLimit)
        return result == .completed
    }

    @discardableResult
    internal func waitForVisible(timeLimit: TimeInterval = WaitLimit.short) -> Bool {
        return waitFor(condition: "visible == true", timeLimit)
    }

    @discardableResult
    internal func waitForHide(timeLimit: TimeInterval = WaitLimit.short) -> Bool {
        return waitFor(condition: "visible == false", timeLimit)
    }

}
