import XCTest
import Nimble

class MainScreen: AbstractScreen {

    let app = XCUIApplication()

    override var rootElement: XCUIElement {
        return gifTable
    }

    private var gifTable: XCUIElement { app.tables["gifTableView"] }


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
