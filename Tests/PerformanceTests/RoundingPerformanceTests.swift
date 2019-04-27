import XCTest
import Swim

class RoundingPerformanceTests: XCTestCase {
    func testFloor() {
        var image = Image<RGBA, Double>(width: 3840, height: 2160, value: 1)
        
        measure {
            image.round()
        }
    }
    
    func testCeil() {
        var image = Image<RGBA, Double>(width: 3840, height: 2160, value: 1)
        
        measure {
            image.round()
        }
    }
    
    func testRound() {
        var image = Image<RGBA, Double>(width: 3840, height: 2160, value: 1)
        
        measure {
            image.round()
        }
    }
}