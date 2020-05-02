import XCTest
import Nimble

extension XCUIElement {

    internal func writeText(_ text: String) {
        expect(self.waitForExistence(timeout: 3)).to(beTrue(), description: "Поле ввода [\(self.identifier)] не найдено")
        self.tap()

        text.forEach({ // имитируем побуквенный ввод пользователем
            self.typeText("\($0)")
        })

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

    /// Частичная видимость подразумевает что наш элемент имеет пересечение с видимой областью
    public var partialVisible: Bool {
        return self.exists
            && XCUIApplication().windows.element(boundBy: 0).frame.intersects(self.frame)
            && false == self.frame.isEmpty
    }


    private func isVisibleOn(app: XCUIApplication) -> Bool {
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
    internal func waitForVisible(_ timeLimit: TimeInterval = WaitLimit.short) -> Bool {
        return waitFor(condition: "visible == true", timeLimit)
    }

    @discardableResult
    internal func waitForHide(_ timeLimit: TimeInterval = WaitLimit.medium) -> Bool {
        return waitFor(condition: "visible == false", timeLimit)
    }

    @discardableResult
    internal func waitForStopProgress(_ timeLimit: TimeInterval = WaitLimit.medium) -> Bool {
        guard self.elementType == ElementType.activityIndicator else {
            fatalError("Метод неприменим для \(self.elementType)")
        }
        // не очень понимаю изза чего некоторые индикаторы загрузки вместо исчезновения переходят в состояние 'Progress halted'
        // трафик слушал, обрывов по вине сервера не замечал, сам клиент иногда прекращает соединение
        // пока воткнул костыль, но нужно консультироваться с разработкой
        return waitFor(condition: "exists == false OR (exists == true AND label != \"In progress\")", timeLimit)
    }

    /// некоторые элементы с точки зрения XCUITest не нажимабельные,  workaround чтобы мочь тапнуть во что бы то ни стало
    internal func hit() {
        if self.isHittable {
            self.tap()
        } else {
            let coordinate = self.coordinate(withNormalizedOffset: CGVector.zero)
            coordinate.tap()
        }
    }

    func scrollToTop() {
        // https://www.alloc-init.com/blog/2019.08.08
        if #available(iOS 13, *) {
            let systemApp = XCUIApplication(bundleIdentifier: "com.apple.springboard")
            systemApp.statusBars.firstMatch.hit()
        } else {
            XCUIApplication().statusBars.firstMatch.tap()
        }
    }

}
