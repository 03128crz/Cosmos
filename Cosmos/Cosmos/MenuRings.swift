// Copyright © 2016 C4
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to
// deal in the Software without restriction, including without limitation the
// rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
// sell copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions: The above copyright
// notice and this permission notice shall be included in all copies or
// substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.


import UIKit

public class MenuRings : CanvasController {
    
    var thickRingFrames: [Rect]!
    var thickRing: Circle!
    var thickRingOut: ViewAnimation?
    var thickRingIn: ViewAnimation?
    
    var thinRings: [Circle]!
    var thinRingFrames: [Rect]!
    var thinRingOut: ViewAnimationSequence?
    var thinRingIn: ViewAnimationSequence?
    
    var dashedRings: [Circle]!
    var revealDashedRings: ViewAnimation?
    var hideDashedRings: ViewAnimation?
    
    var menuDividingLines: [Line]!
    
    var menuIsVisible = false
    
    public override func setup() {
        canvas.backgroundColor = clear
        canvas.frame = Rect(0,0,80,80)
        createRingsLines()
        createRingsLinesAnimations()
    }
    
    func createMenuDividingLines() {
        menuDividingLines = [Line]()
        
        for i in 0...11 {
            let line = Line((Point(), Point(54, 0)))
            line.anchorPoint = Point(-1.88888, 0)
            line.center = canvas.center
            line.transform = Transform.makeRotation(M_PI / 6.0 * Double(i), axis: Vector(x: 0, y: 0, z: -1))
            line.lineCap = .Butt
            line.strokeColor = cosmosblue
            line.lineWidth = 1.0
            line.strokeEnd = 0.0
            canvas.add(line)
            menuDividingLines.append(line)
        }
    }
    
    func createShortDashedRing() {
        let shortDashedRing = Circle(center: canvas.center, radius: 82 + 2)
        let pattern = [1.465, 1.465, 1.465, 1.465, 1.465, 1.465, 1.465, 1.465 * 3.0] as [NSNumber]
        shortDashedRing.lineDashPattern = pattern
        shortDashedRing.strokeEnd = 0.995
        
        let angle = degToRad(-1.5)
        let rotation = Transform.makeRotation(angle)
        shortDashedRing.transform = rotation
        
        shortDashedRing.lineWidth = 0.0
        dashedRings.append(shortDashedRing)
    }
    
    func createLongDashedRing() {
        let longDashedRing = Circle(center: canvas.center, radius: 82 + 2)
        longDashedRing.lineWidth = 0.0
        
        let pattern = [1.465, 1.465 * 9.0] as [NSNumber]
        longDashedRing.lineDashPattern = pattern
        longDashedRing.strokeEnd = 0.995
        
        let angle = degToRad(0.5)
        let rotation = Transform.makeRotation(angle)
        longDashedRing.transform = rotation
        
        let mask = Circle(center: longDashedRing.bounds.center, radius: 82 + 4)
        mask.fillColor = clear
        mask.lineWidth = 8
        longDashedRing.layer?.mask = mask.layer
        
        dashedRings.append(longDashedRing)
    }
    
    func createDashedRings() {
        dashedRings = [Circle]()
        createShortDashedRing()
        createLongDashedRing()
        
        for ring in self.dashedRings {
            ring.strokeColor = cosmosblue
            ring.fillColor = clear
            ring.interactionEnabled = false
            ring.lineCap = .Butt
            self.canvas.add(ring)
        }
    }
    
    func createThickRing() {
        let inner = Circle(center: canvas.center, radius: 14)
        let outer = Circle(center: canvas.center, radius: 255)
        
        thickRingFrames = [inner.frame, outer.frame]
        
        inner.fillColor = clear
        inner.lineWidth = 3
        inner.strokeColor = cosmosblue
        inner.interactionEnabled = false
        thickRing = inner
        
        canvas.add(thickRing)
    }
    
    func createThinRings() {
        thinRings = [Circle]()
        thinRings.append(Circle(center: canvas.center, radius: 8))
        thinRings.append(Circle(center: canvas.center, radius: 56))
        thinRings.append(Circle(center: canvas.center, radius: 78))
        thinRings.append(Circle(center: canvas.center, radius: 98))
        thinRings.append(Circle(center: canvas.center, radius: 102))
        thinRings.append(Circle(center: canvas.center, radius: 156))
        
        thinRingFrames = [Rect]()
        for i in 0..<self.thinRings.count {
            
            let ring = self.thinRings[i]
            ring.fillColor = clear
            ring.lineWidth = 1
            ring.strokeColor = cosmosblue
            ring.interactionEnabled = false
            if i > 0 {
                ring.opacity = 0.0
            }
            self.thinRingFrames.append(ring.frame)
            canvas.add(ring)
        }
    }
    
    //MARK: Animations
    func createThickRingAnimations() {
        thickRingOut = ViewAnimation(duration: 0.5) {
            
            self.thickRing.frame = self.thickRingFrames[1]
        }
        thickRingOut?.curve = .EaseOut
            
        thickRingIn = ViewAnimation(duration: 0.5) {
            self.thickRing.frame = self.thickRingFrames[0]
        }
        thickRingIn?.curve = .EaseOut
    }
    
    func createThinRingsOutAnimations() {
        var animationArray = [ViewAnimation]()
        for i in 0..<self.thinRings.count - 1 {
            let anim = ViewAnimation(duration: 0.075 + Double(i) * 0.01) {
                let circle = self.thinRings[i]
                if i > 0 {
                    ViewAnimation(duration: 0.0375) {
                        circle.opacity = 1.0
                    }.animate()
                }
                
                circle.frame = self.thinRingFrames[i + 1]
            }
            anim.curve  = .EaseOut
            animationArray.append(anim)
        }
        thinRingOut = ViewAnimationSequence(animations: animationArray)
    }
    
    func createThinRingsInAnimations() {
        var animationArray = [ViewAnimation]()
        for i in 1..<self.thinRings.count {
            let anim = ViewAnimation(duration: 0.075 + Double(i) * 0.01) {
                let circle = self.thinRings[self.thinRings.count - i]
                if self.thinRings.count - i > 0 {
                    ViewAnimation(duration: 0.0375) {
                        circle.opacity = 0.0
                    }.animate()
                }
                circle.frame = self.thinRingFrames[self.thinRings.count - i]
            }
            anim.curve = .EaseOut
            animationArray.append(anim)
        }
        thinRingIn = ViewAnimationSequence(animations: animationArray)
    }
    
    func createDashedRingAnimations() {
        revealDashedRings = ViewAnimation(duration: 0.25) {
            self.dashedRings[0].lineWidth = 4
            self.dashedRings[1].lineWidth = 12
        }
        revealDashedRings?.curve = .EaseOut
        
        hideDashedRings = ViewAnimation(duration: 0.25) {
            self.dashedRings[0].lineWidth = 0
            self.dashedRings[1].lineWidth = 0
        }
        hideDashedRings?.curve = .EaseOut
    }
    
    func revealHideDividingLines(target: Double) {
        var indices = [0,1,2,3,4,5,6,7,8,9,10,11]
        
        for i in 0...11 {
            wait(0.05 * Double(i)) {
                let randomIndex = random(below: indices.count)
                let index = indices[randomIndex]
                
                ViewAnimation(duration: 0.1) {
                    self.menuDividingLines[index].strokeEnd = target
                }.animate()
                
                indices.removeAtIndex(randomIndex)
            }
        }
    }
    
    func createRingsLines() {
        createThickRing()
        createThinRings()
        createDashedRings()
        createMenuDividingLines()
    }
    
    func createRingsLinesAnimations() {
        createThickRingAnimations()
        createThinRingsInAnimations()
        createThinRingsOutAnimations()
        createDashedRingAnimations()
    }
}