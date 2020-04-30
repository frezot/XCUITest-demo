import XCTest

extension XCUIElementQuery {

    subscript(index: Int) -> XCUIElement {
        return self.element(boundBy: index)
    }
}

extension XCUIElementQuery: Sequence {
    public func makeIterator() -> AnyIterator<XCUIElement> {
        // подсмотрел тут: https://onmyway133.com/blog/how-to-iterate-over-xcuielementquery-in-uitests/
        var index = UInt(0)
        return AnyIterator {
            guard index < self.count else { return nil }

            let element = self.element(boundBy: Int(index))
            index = index + 1
            return element
        }
    }
}
