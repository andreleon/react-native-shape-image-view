//
//  RNHexagonView.swift
//

import UIKit

@objc(RNHexagonView)
class RNHexagonView: UIView {
    
    private var _borderColor: UIColor = .clear
    private var _borderWidth: CGFloat = 0
    private var _backgroundColor: UIColor = .clear
    private var _isHorizontal: Bool = false
    private var _size: CGFloat = 0
    private var _cornerRadius: CGFloat = 0
    
    private var borderLayer = CAShapeLayer()
    
    var size: NSNumber? {
        set {
            let newSize = RCTConvert.cgFloat(newValue)
            self.frame.size.width = newSize
            self.frame.size.height = newSize
            self.setNeedsDisplay()
        }
        get {
            return nil
        }
    }
    
    var borderWidth: NSNumber? {
        set {
            self._borderWidth = RCTConvert.cgFloat(newValue)
            self.setNeedsDisplay()
        }
        get {
            return nil
        }
    }
    
    var borderColor: NSString? {
        set {
            if newValue != nil {
                let color = NumberFormatter().number(from: newValue! as String)
                self._borderColor = RCTConvert.uiColor(color)
                self.setNeedsDisplay()
            }
        }
        get {
            return nil
        }
    }
    
    var background_Color: NSString? {
        set {
            if newValue != nil {
                let color = NumberFormatter().number(from: newValue! as String)
                self._backgroundColor = RCTConvert.uiColor(color)
                self.setNeedsDisplay()
            }
        }
        get {
            return nil
        }
    }
    
    var isHorizontal: NSNumber? {
        set {
            if let horizontal = newValue {
                if self._isHorizontal != RCTConvert.bool(horizontal) {
                    self._isHorizontal = RCTConvert.bool(horizontal)
                    self.setNeedsDisplay()
                }
            }
        }
        get {
            return nil
        }
    }
    
    var cornerRadius: NSNumber? {
        set {
            self._cornerRadius = RCTConvert.cgFloat(newValue)
            self.setNeedsDisplay()
        }
        get {
            return nil
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        setupHexagonView(view: self)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundColor = self._backgroundColor
        setupHexagonView(view: self)
    }
    
    func setupHexagonView(view: UIView) {
        let lineWidth = self._borderWidth
        let borderColor = self._borderColor
        let cornerRadius = self._cornerRadius
        
        let path = UIBezierPath(polygonIn: view.bounds, sides: 6, lineWidth: lineWidth, cornerRadius: cornerRadius)
        
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        mask.fillColor = UIColor.white.cgColor
        (self.layer as! CAShapeLayer).mask = mask
      
        borderLayer.removeFromSuperlayer()
        
        (self.layer as! CAShapeLayer).path = path.cgPath
        (self.layer as! CAShapeLayer).fillColor = nil
        
        borderLayer.path = path.cgPath
        borderLayer.lineWidth = lineWidth
        borderLayer.strokeColor = borderColor.cgColor
        borderLayer.fillColor = nil
        (self.layer as! CAShapeLayer).addSublayer(borderLayer)
    }

    override class var layerClass: AnyClass {
        return CAShapeLayer.self
    }
  
}
extension UIBezierPath {
  
  /// Create UIBezierPath for regular polygon with rounded corners
  ///
  /// - parameter rect:            The CGRect of the square in which the path should be created.
  /// - parameter sides:           How many sides to the polygon (e.g. 6=hexagon; 8=octagon, etc.).
  /// - parameter lineWidth:       The width of the stroke around the polygon. The polygon will be inset such that the stroke stays within the above square. Default value 1.
  /// - parameter cornerRadius:    The radius to be applied when rounding the corners. Default value 0.
  
  convenience init(polygonIn rect: CGRect, sides: Int, lineWidth: CGFloat = 1, cornerRadius: CGFloat = 0) {
    self.init()
    
    let theta = 2 * CGFloat.pi / CGFloat(sides)                        // how much to turn at every corner
    let offset = cornerRadius * tan(theta / 2)                  // offset from which to start rounding corners
    let squareWidth = min(rect.size.width, rect.size.height)    // width of the square
    
    // calculate the length of the sides of the polygon
    
    var length = squareWidth - lineWidth
    if sides % 4 != 0 {                                         // if not dealing with polygon which will be square with all sides ...
      length = length * cos(theta / 2) + offset / 2           // ... offset it inside a circle inside the square
    }
    let sideLength = length * tan(theta / 2)
    
    // start drawing at `point` in lower right corner, but center it
    
    var point = CGPoint(x: rect.origin.x + rect.size.width / 2 + sideLength / 2 - offset, y: rect.origin.y + rect.size.height / 2 + length / 2)
    var angle = CGFloat.pi
    move(to: point)
    
    // draw the sides and rounded corners of the polygon
    
    for _ in 0 ..< sides {
      point = CGPoint(x: point.x + (sideLength - offset * 2) * cos(angle), y: point.y + (sideLength - offset * 2) * sin(angle))
      addLine(to: point)
      
      let center = CGPoint(x: point.x + cornerRadius * cos(angle + .pi / 2), y: point.y + cornerRadius * sin(angle + .pi / 2))
      addArc(withCenter: center, radius: cornerRadius, startAngle: angle - .pi / 2, endAngle: angle + theta - .pi / 2, clockwise: true)
      
      point = currentPoint
      angle += theta
    }
    
    close()
    
    self.lineWidth = lineWidth           // in case we're going to use CoreGraphics to stroke path, rather than CAShapeLayer
    lineJoinStyle = .round
  }
  
}
