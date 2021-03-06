import XCTest
import Swim

class AffineTransformationTests: XCTestCase {
    func testAffineTransform() {
        do { // Scale
            let a = AffineTransformation.scale(x: 2, y: 3)
            XCTAssertEqual(a,
                           AffineTransformation(a: 2, b: 0, tx: 0,
                                                c: 0, d: 3, ty: 0),
                           accuracy: 0)
        }
        do { // Rotate
            let a = AffineTransformation.rotation(angle: Double.pi/3)
            XCTAssertEqual(a,
                           AffineTransformation(a: 0.5, b: -sqrt(3)/2, tx: 0,
                                                c: sqrt(3)/2, d: 0.5, ty: 0),
                           accuracy: 1e-4)
        }
        do { // Translate
            let a = AffineTransformation.translation(x: 2, y: 3)
            XCTAssertEqual(a,
                           AffineTransformation(a: 1, b: 0, tx: 2,
                                                c: 0, d: 1, ty: 3),
                           accuracy: 1e-4)
        }
        do { // Inverse
            let a = AffineTransformation.scale(x: 2, y: 3)
                * .translation(x: 2, y: 3)
                * .rotation(angle: 1.0)
            let id = try! a * a.inverted()
            XCTAssertEqual(id,
                           AffineTransformation.identity,
                           accuracy: 1e-4)
        }
    }
    
    static let allTests = [
        ("testAffineTransform", testAffineTransform)
    ]
}

private func XCTAssertEqual(_ expression1: AffineTransformation,
                            _ expression2: AffineTransformation,
                            accuracy: Double,
                            file: StaticString = #file,
                            line: UInt = #line) {
    XCTAssertEqual(expression1.a, expression2.a, accuracy: accuracy, file: file, line: line)
    XCTAssertEqual(expression1.b, expression2.b, accuracy: accuracy, file: file, line: line)
    XCTAssertEqual(expression1.tx, expression2.tx, accuracy: accuracy, file: file, line: line)
    XCTAssertEqual(expression1.c, expression2.c, accuracy: accuracy, file: file, line: line)
    XCTAssertEqual(expression1.d, expression2.d, accuracy: accuracy, file: file, line: line)
    XCTAssertEqual(expression1.ty, expression2.ty, accuracy: accuracy, file: file, line: line)
}
