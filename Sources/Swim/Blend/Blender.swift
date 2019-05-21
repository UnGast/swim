public protocol Blender {
    associatedtype T: FloatingPoint
    static func blend(topColor: T, bottomColor: T) -> T
}

extension Blender {
    @inlinable
    public static func blend<P: NoAlpha>(top: Image<P, T>, bottom: inout Image<P, T>) {
        precondition(top.size == bottom.size)
        
        for i in 0..<top.data.count {
            bottom.data[i] = blend(topColor: top.data[i],
                                   bottomColor: bottom.data[i])
        }
    }
}

public struct AdditiveBlender<T: FloatingPoint>: Blender {
    @inlinable
    public static func blend(topColor: T, bottomColor: T) -> T {
        return min(topColor + bottomColor, 1)
    }
}

public struct MultiplyBlender<T: FloatingPoint>: Blender {
    @inlinable
    public static func blend(topColor: T, bottomColor: T) -> T {
        return topColor*bottomColor
    }
}

public struct ScreenBlender<T: FloatingPoint>: Blender {
    @inlinable
    public static func blend(topColor: T, bottomColor: T) -> T {
        return 1 - (1 - topColor)*(1 - bottomColor)
    }
}

public struct OverlayBlender<T: FloatingPoint>: Blender {
    @inlinable
    public static func blend(topColor: T, bottomColor: T) -> T {
        if 2*topColor < 1 {
            return 2 * topColor * bottomColor
        } else {
            return 1 - 2 * (1 - topColor)*(1 - bottomColor)
        }
    }
}

public enum BlendMode {
    case additive, multiply, screen, overlay
}

extension Image where P: NoAlpha, T: FloatingPoint {
    @inlinable
    public mutating func blend(image: Image<P, T>, mode: BlendMode) {
        switch mode {
        case .additive:
            AdditiveBlender.blend(top: image, bottom: &self)
        case .multiply:
            MultiplyBlender.blend(top: image, bottom: &self)
        case .screen:
            ScreenBlender.blend(top: image, bottom: &self)
        case .overlay:
            OverlayBlender.blend(top: image, bottom: &self)
        }
    }
}
