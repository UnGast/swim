
import Foundation
import CStbImage

extension Image where T: BinaryFloatingPoint {
    func _resized(width: Int, height: Int) -> Image<P, T> {
        
        var baseImage = self
        if width < baseImage.width {
            baseImage = baseImage.resizeaa(width: width, height: baseImage.height)
        }
        if height < baseImage.height {
            baseImage = baseImage.resizeaa(width: baseImage.width, height: height)
        }
        if width > baseImage.width || height > baseImage.height {
            baseImage = baseImage.resizebn(width: width, height: height)
        }
        return baseImage
    }
    
    public func resized(width: Int, height: Int) -> Image<P, T> {
        return _resized(width: width, height: height)
    }
}

extension Image {
    /// Resize image with Narest Neighbor algorithm.
    func _resizenn(width: Int, height: Int) -> Image<P, T> {
        var newImage = Image<P, T>(width: width, height: height)
        
        let scaleX = Double(width) / Double(self.width)
        let scaleY = Double(height) / Double(self.height)
        
        for y in 0..<height {
            let yp = min(Int(Foundation.round(Double(y) / scaleY)), self.height - 1)
            
            for x in 0..<width {
                let xp = min(Int(Foundation.round(Double(x) / scaleX)), self.width - 1)
                
                newImage[x, y] = self[xp, yp]
            }
        }
        
        return newImage
    }
    
    public func resizenn(width: Int, height: Int) -> Image<P, T> {
        return _resizenn(width: width, height: height)
    }
}

extension Image where T: BinaryFloatingPoint {
    /// Resize image with Area Average algorithm.
    func _resizeaa(width: Int, height: Int) -> Image<P, T> {
        
        let xScaleImage: Image<P, T>
        if width != self.width {
            let baseImage = self
            var newImage = Image<P, T>(width: width, height: self.height, value: 0)
            let scaleX = T(self.width-1) / T(width)
            for y in 0..<self.height {
                for x in 0..<width {
                    let startX = T(x) * scaleX
                    let endX = T(x+1) * scaleX
                    
                    let ceilStartX = Foundation.ceil(startX)
                    let floorEndX = Foundation.floor(endX)
                    if ceilStartX < floorEndX {
                        if startX < ceilStartX {
                            let dx = Int(Foundation.floor(startX))
                            let len: T = ceilStartX - startX
                            newImage[x, y] += baseImage[dx, y] * len
                        }
                        for dx in Int(ceilStartX)...Int(floorEndX) {
                            newImage[x, y] += baseImage[dx, y]
                        }
                        if floorEndX < endX {
                            let dx = Int(Foundation.ceil(endX))
                            let len: T = endX - floorEndX
                            newImage[x, y] += baseImage[dx, y] * len
                        }
                        newImage[x, y] /= scaleX
                    } else {
                        newImage[x, y] = baseImage[Int(ceilStartX), y]
                    }
                }
            }
            xScaleImage = newImage
        } else {
            xScaleImage = self
        }
        
        let yScaleImage: Image<P, T>
        if height != self.height {
            let baseImage = xScaleImage
            var newImage = Image<P, T>(width: width, height: height, value: 0)
            let scaleY = T(self.height-1) / T(height)
            for y in 0..<height {
                let startY = T(y) * scaleY
                let endY = T(y+1) * scaleY
                
                let ceilStartY = Foundation.ceil(startY)
                let floorEndY = Foundation.floor(endY)
                
                for x in 0..<width {
                    if ceilStartY < floorEndY {
                        if startY < ceilStartY {
                            let dy = Int(Foundation.floor(startY))
                            let len: T = ceilStartY - startY
                            newImage[x, y] += baseImage[x, dy] * len
                        }
                        for dy in Int(ceilStartY)...Int(floorEndY) {
                            newImage[x, y] += baseImage[x, dy]
                        }
                        if floorEndY < endY {
                            let dy = Int(Foundation.ceil(endY))
                            let len: T = endY - floorEndY
                            newImage[x, y] += baseImage[x, dy] * len
                        }
                        newImage[x, y] /= scaleY
                    } else {
                        newImage[x, y] = baseImage[x, Int(ceilStartY)]
                    }
                }
            }
            yScaleImage = newImage
        } else {
            yScaleImage = xScaleImage
        }
        
        return yScaleImage
    }
    
    public func resizeaa(width: Int, height: Int) -> Image<P, T> {
        return _resizeaa(width: width, height: height)
    }
}

extension Image where T: BinaryFloatingPoint {
    /// Resize image with Bilinear interpolation.
    func _resizebn(width: Int, height: Int) -> Image<P, T> {
        
        let baseImage: Image<P, T>
        do {
            var image = self
            if width*2 < self.width {
                var newWidth = self.width >> 1
                while width*2 < newWidth {
                    newWidth >>= 1
                }
                image = image._resizeaa(width: newWidth, height: image.height)
            }
            if height*2 < self.height {
                var newHeight = self.height >> 1
                while height*2 < newHeight {
                    newHeight >>= 1
                }
                image = image._resizeaa(width: image.width, height: newHeight)
            }
            baseImage = image
        }
        
        var newImage = Image<P, T>(width: width, height: height)

        let scaleX = T(baseImage.width) / T(width)
        let scaleY = T(baseImage.height) / T(height)

        for y in 0..<height {
            let yp = (T(y) + 0.5) * scaleY
            let yy = Int(Foundation.floor(yp))
            let yy1 = min(yy+1, baseImage.height-1)
            let yy1yp: T = T(yy1) - yp
            let ypyy: T = yp - T(yy)
            
            for x in 0..<width {
                let xp = (T(x) + 0.5) * scaleX
                let xx = Int(Foundation.floor(xp))
                let xx1 = min(xx+1, baseImage.width-1)
                let xx1xp: T = T(xx1) - xp
                let xpxx: T = xp - T(xx)

                let plu: Pixel<P, T> = yy1yp * baseImage[xx, yy]
                let pru: Pixel<P, T> = ypyy * baseImage[xx, yy1]
                let pu: Pixel<P, T> = plu + pru

                let pld: Pixel<P, T> = yy1yp * baseImage[xx1, yy]
                let prd: Pixel<P, T> = ypyy * baseImage[xx1, yy1]
                let pd: Pixel<P, T> = pld + prd

                let px1: Pixel<P, T> = xx1xp * pu
                let px2: Pixel<P, T> = xpxx * pd
                let px: Pixel<P, T> = px1 + px2

                newImage[x, y] = px
            }
        }

        return newImage
    }
    
    public func resizebn(width: Int, height: Int) -> Image<P, T> {
        return _resizebn(width: width, height: height)
    }
}

