/// Reference to pixel in image.
///
/// It contains `UnsafeMutableBufferPointer` which pointing images buffer.
/// `UnsafePixelRef` is created only inside `withUnsafeMutableBufferPointer`'s body.
/// Since `withUnsafeMutableBufferPointer` 's argument is valid only for the duration of the method’s execution, `UnsafePixelRef` is also valid only for the duration of the methods' execution.
///
/// Usages:
/// - `Image<P, T>.createWithUnsafePixelRef`
/// - `Image<P, T>.withUnsafePixelRef`
/// - `Image<P, T>.unsafePixelwiseConvert`
/// - `Image<P, T>.unsafePixelwiseConverted`
public struct UnsafePixelRef<P: PixelType, T: DataType> {
    public let x: Int
    public let y: Int
    
    public var pointer: UnsafeMutableBufferPointer<T>
    
    @inlinable
    init(x: Int, y: Int, pointer: UnsafeMutableBufferPointer<T>) {
        assert(pointer.count == P.channels)
        self.x = x
        self.y = y
        self.pointer = pointer
    }
    
    @inlinable
    init(x: Int, y: Int, rebasing slice: Slice<UnsafeMutableBufferPointer<T>>) {
        self.init(x: x, y: y, pointer: UnsafeMutableBufferPointer(rebasing: slice))
    }
}

extension UnsafePixelRef {
    @inlinable
    public subscript(channel: Int) -> T {
        get {
            return pointer[channel]
        }
        nonmutating set {
            pointer[channel] = newValue
        }
    }
    
    @inlinable
    public subscript(channel: P) -> T {
        get {
            return self[channel.rawValue]
        }
        nonmutating set {
            self[channel.rawValue] = newValue
        }
    }
}

extension UnsafePixelRef {
    @inlinable
    public func initialize(channel: P, to value: T) {
        initialize(channel: channel.rawValue, to: value)
    }
    
    @inlinable
    public func initialize(channel: Int, to value: T) {
        pointer.baseAddress!.advanced(by: channel).initialize(to: value)
    }
    
    @inlinable
    public func initialize(to color: Color<P, T>) {
        var p = pointer.baseAddress!
        for i in 0..<P.channels {
            p.pointee = color[i]
            p.initialize(to: color[i])
            p += 1
        }
    }
}

extension UnsafePixelRef where T == UInt8 {
    @inlinable
    public func initialize(to color: Color<P, T>) {
        let rawPointer = UnsafeMutableRawBufferPointer(pointer)
        rawPointer.copyMemory(from: color.dataPointer)
    }
}

// MARK: - Image extension
extension Image {
    /// Create `UnsafePixelRef` pointing specified coord and execute `body`.
    ///
    /// For raster scan, using `pixels()` or `unsafePixelwiseConvert(_:)` is better.
    @inlinable
    public mutating func withUnsafePixelRef<R>(x: Int, y: Int, _ body: (UnsafePixelRef<P, T>)->R) -> R {
        let start = dataIndex(x: x, y: y)
        return data.withUnsafeMutableBufferPointer {
            let slice = $0[start..<start+P.channels]
            let ref = UnsafePixelRef<P, T>(x: x, y: y, rebasing: slice)
            return body(ref)
        }
    }
}
