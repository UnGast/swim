import XCTest
import Swim

class InterpolatorPerformanceTests: XCTestCase {

    func testNN() {
        let image = Image<RGBA, UInt8>(width: 640, height: 480, value: 1)
        let targetWidth = 1000
        let targetHeight = 1000
        var target = Image<RGBA, UInt8>(width: targetWidth, height: targetHeight, value: 1)
        
        let intpl = NearestNeighborInterpolator<RGBA, UInt8>(edgeMode: .constant(color: Color<RGBA, UInt8>(rgba: [255, 255, 255, 255])))
        
        measure {
            target.withUnsafePixelRef(x: 0, y: 0) { ref in
                for y in 0..<targetHeight {
                    for x in 0..<targetWidth {
                        intpl.interpolate(x: Double(x) * Double(image.width) / Double(targetWidth),
                                          y: Double(y) * Double(image.height) / Double(targetHeight),
                                          in: image, into: ref)
                    }
                }
            }
        }
    }

    func testBL() {
        let image = Image<RGBA, Double>(width: 640, height: 480, value: 1)
        var target = Image<RGBA, Double>(width: 1, height: 1, value: 1)
        
        let intpl = BilinearInterpolator<RGBA, Double>(edgeMode: .edge)
        
        measure {
            target.withUnsafePixelRef(x: 0, y: 0) { ref in
                for y in 0..<2160 {
                    for x in 0..<3840 {
                        intpl.interpolate(x: Double(x) * Double(image.width) / 3840,
                                          y: Double(y) * Double(image.height) / 2160,
                                          in: image, into: ref)
                    }
                }
            }
        }
    }
    
    func testBC() {
        let image = Image<RGBA, Double>(width: 640, height: 480, value: 1)
        var target = Image<RGBA, Double>(width: 1, height: 1, value: 1)
        
        let intpl = BicubicInterpolator<RGBA, Double>(edgeMode: .edge)
        
        measure {
            target.withUnsafePixelRef(x: 0, y: 0) { ref in
                for y in 0..<2160 {
                    for x in 0..<3840 {
                        intpl.interpolate(x: Double(x) * Double(image.width) / 3840,
                                          y: Double(y) * Double(image.height) / 2160,
                                          in: image, into: ref)
                    }
                }
            }
        }
    }
}
