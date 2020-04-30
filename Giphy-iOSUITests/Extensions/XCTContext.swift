import XCTest

extension XCTContext {

    // https://medium.com/xcblog/bdd-using-xctactivity-feature-of-xcuitest-90ea97aee449

    @discardableResult
    static func step<T>(_ text: String, block: (() -> T) ) -> T {
        return self.runActivity(named: text) { _  in
            return block()
        }
    }

    static func info(_ text: String) {
        return self.runActivity(named: text) {_ in }
    }
}
