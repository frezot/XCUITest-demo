import XCTest
import Nimble

class MainScreen: AbstractScreen {

    let app = XCUIApplication()

    override var rootElement: XCUIElement {
        return gifTable
    }

    private lazy var gifTable = app.tables["gifTableView"]
    private lazy var searchBar = app.otherElements["searchBar"]
    private lazy var noResultsView = app.otherElements["noResultsView"]
    private lazy var errorView = app.otherElements["errorView"]

    @discardableResult
    func screenHeaderIs(_ expectation: String) -> Self {
        return XCTContext.step("Проверяем заголовок экрана") {
            expect(self.app.staticTexts["screenHeader"].label).to(equal(expectation))
            return self
        }
    }

    @discardableResult
    func checkSearchBar(placeholder: String) -> Self {
        return XCTContext.step("Првоеряем видимость и корректность SearchBar-элементов") {
            expect(self.searchBar.visible).to(beTrue(), description: "SearchBar отсутсвует или не виден")
            expect(self.searchBar.searchFields.element.placeholderValue).to(equal(placeholder), description: "Рlaceholder поисковой строки")
            return self
        }
    }

    @discardableResult
    func search(for query: String) -> Self {
        return XCTContext.step("В качестве поискового запроса вводим: \"\(query)\"") {
            searchBar.searchFields.element.writeText(query)
            expect(self.searchBar.buttons["Clear text"].visible).to(beTrue(), description: "При не-пустой поисковой строке должен отображаться 'крестик' очистки")
            return self
        }
    }

    @discardableResult
    func searchResultIsEmpty(failText: String) -> Self {
        return XCTContext.step("Проверяем как отображается '\(failText)'-вьюха") {

            expect(self.noResultsView.isHittable).to(beTrue())
            expect(self.gifTable.isHittable).to(beFalse()) // через isHittable проверяем что одна вьюха лежит поверх другой

            expect(self.app.staticTexts["noResultsViewTitle"].label).to(equal(failText))
            return self
        }
    }


    @discardableResult
    func checkErrorView(failText: String) -> Self {
        return XCTContext.step("Проверяем как отображается '\(failText)' ошибка") {

            expect(self.errorView.visible).to(beTrue())

            expect(self.app.staticTexts["errorViewTitle"].label).to(equal(failText))
            let button = app.buttons["errorViewButton"]
            expect(button.label).to(equal("Refresh"))
            expect(button.isHittable).to(beTrue(), description: "Кнопка не isHittable")
            return self
        }
    }

    @discardableResult
    func topImageIs(_ imagename: String) -> Self {
        return XCTContext.step("Ожидаем что изображение [\(imagename)] будет первым в таблице") {

            let image = gifTable.cells[0].images[imagename]

            expect(image.visible).to(beTrue(), description: "Картинка не отображается")
            expect(image.frame.height).to(beGreaterThan(20), description:
                "Проблемы с размером изображения. [\(image.frame.width)x\(image.frame.height)]")
            return self
        }
    }

    @discardableResult
    func clearSearchBar() -> Self {
        return XCTContext.step("Удаляем поисковой запрос кнопкой очистки") {

            self.searchBar.buttons["Clear text"].tap()

            expect(self.noResultsView.waitForHide()).to(beTrue(), description: "После очистки результатов поиска не может отображаться noResultsView")
            expect(self.gifTable.isHittable).to(beTrue(), description: "На первый план должна выйти gifTable")
            return self
        }
    }

    @discardableResult
    func checkSearching(request: String, result: String) -> Self {
        return XCTContext.step("По запросу '\(request)' ожидаем что найдет изображение [\(result)]") {
            return self.search(for: request)
                       .waitForFirstResponse(WaitLimit.short)
                       .topImageIs(result)
                       .clearSearchBar()
        }
    }

    @discardableResult
    func waitForFirstResponse(_ timelimit: TimeInterval) -> Self {
        return XCTContext.step("Ждем первого успешного файла от сервера") {

            let loader = gifTable.activityIndicators.firstMatch
            expect(loader.waitForStopProgress(timelimit)).to(beTrue(), description: "Загрузка первого элемента не остановилась в установленные временные рамки  \n\n \(app.debugDescription)")

            return self
        }
    }

    @discardableResult
    func scrollDown(nTimes n: Int) -> Self {
        return XCTContext.step("Скролим ленту \(n) раз(а)") {
            for _ in 1 ... n {
                app.swipeUp()
            }
            return self
        }
    }

    @discardableResult
    func contentLoadingShouldComplete(_ timelimit: TimeInterval) -> Self {

        return XCTContext.step("Ждем остановки ВСЕХ индикаторов загрузки") {
            app.activityIndicators.forEach({
                expect($0.waitForStopProgress(timelimit)).to(beTrue(), description: "Индикатор загрузки не остановился \n\n \(app.debugDescription)")
            })
            return self
        }
    }

    @discardableResult
    func contentIsFine() -> Self {
        return XCTContext.step("Убеждаемся что лента успешно загруженна, ошибок нет") {
            // идея -- нужно обойти ленту снизу-вверх и оперделить сколько ячеек видимы для пользователя
            // на видимых ячейках в свою очередь проверить что картинки загружены
            for i in (0 ..< gifTable.cells.count).reversed() {
                let tableCell = gifTable.cells[i]

                if tableCell.visible || tableCell.partialVisible {
                    for image in tableCell.images {
                        expect(image.identifier).notTo(equal(""), description:
                            "У изображения остуствует идентификатор, скорее всего при загрузке возникла проблема")
                        expect(image.frame.height).to(beGreaterThan(20), description:
                            "Проблемы с размером изображения. [\(image.frame.width)x\(image.frame.height)]")
                    }
                }
            }
            return self
        }
    }

    @discardableResult
    func scrollToTopShouldWorks() -> Self {
        return XCTContext.step("Делаем стандартный scrollToTop, убеждаемся что лента вернулась к первой записи") {

            gifTable.scrollToTop()

            let top = gifTable.cells["row0"]
            expect(top.visible).to(beTrue(), description: "Сломался scrollToTop")

            for image in top.images {
                expect(image.identifier).notTo(equal(""), description:
                    "У изображения остуствует идентификатор, скорее всего при загрузке возникла проблема")
                expect(image.frame.height).to(beGreaterThan(20), description:
                    "Проблемы с размером изображения. [\(image.frame.width)x\(image.frame.height)]")
            }

            return self
        }
    }

}
