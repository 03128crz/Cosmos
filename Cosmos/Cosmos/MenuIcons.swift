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

public class MenuIcons : CanvasController {
    
    var signIcons: [String:Shape]!
    var innerTargets: [Point]!
    var outerTargets: [Point]!
    
    var signIconsOut: ViewAnimation!
    var signIconsIn: ViewAnimation!
    var revealSignIcons: ViewAnimation!
    var hideSignIcons: ViewAnimation!
    
    public override func setup() {
        canvas.frame = Rect(0,0,80,80)
        canvas.backgroundColor = clear
        createSignIcons()
        createSignIconAnimations()
    }
    
    func createSignIcons() {
        signIcons = [String:Shape]()
        signIcons["aries"] = aries()
        signIcons["taurus"] = taurus()
        signIcons["gemini"] = gemini()
        signIcons["cancer"] = cancer()
        signIcons["leo"] = leo()
        signIcons["virgo"] = virgo()
        signIcons["libra"] = libra()
        signIcons["scorpio"] = scorpio()
        signIcons["sagittarius"] = sagittarius()
        signIcons["capricorn"] = capricorn()
        signIcons["aquarius"] = aquarius()
        signIcons["pisces"] = pisces()
        
        for shape in [Shape](self.signIcons.values) {
            shape.strokeEnd = 0.001
            shape.lineCap = .Round
            shape.lineJoin = .Round
            
            shape.transform = Transform.makeScale(0.64, 0.64, 1.0)
            shape.lineWidth = 2
            shape.strokeColor = white
            shape.fillColor = clear
        }
        
        positionSignIcons()
    }
    
    func positionSignIcons() {
        innerTargets = [Point]()
        let provider = AstrologicalSignProvider.sharedInstance
        let r = 10.5
        let dx = canvas.center.x
        let dy = canvas.center.y
        
        for i in 0..<provider.order.count {
            let ϴ = M_PI / 6 * Double(i)
            let name = provider.order[i]
            if let sign = signIcons[name] {
                sign.center = Point(r * cos(ϴ) + dx, r * sin(ϴ) + dy)
                canvas.add(sign)
                sign.anchorPoint = Point(0.5, 0.5)
                innerTargets.append(sign.center)
            }
        }
        
        outerTargets = [Point]()
        for i in 0..<provider.order.count {
            let r = 129.0
            let ϴ = M_PI / 6 * Double(i) + M_PI / 12.0
            outerTargets.append(Point(r * cos(ϴ) + dx, r * sin(ϴ) + dy))
        }
    }
    
    func createSignIconAnimations() {
        
        revealSignIcons = ViewAnimation(duration: 0.5) {
            for sign in [Shape](self.signIcons.values) {
                sign.strokeEnd = 1.0
            }
        }
        revealSignIcons.curve = .EaseOut

        hideSignIcons = ViewAnimation(duration: 0.5) {
            for sign in [Shape](self.signIcons.values) {
                sign.strokeEnd = 0.001
            }
        }
        hideSignIcons.curve = .EaseOut
        
        signIconsOut = ViewAnimation(duration: 0.33) {
            for i in 0..<AstrologicalSignProvider.sharedInstance.order.count {
                let name = AstrologicalSignProvider.sharedInstance.order[i]
                if let sign = self.signIcons[name] {
                    sign.center = self.outerTargets[i]
                }
            }
        }
        signIconsOut.curve = .EaseOut
        
        signIconsIn = ViewAnimation(duration: 0.33) {
            for i in 0..<AstrologicalSignProvider.sharedInstance.order.count {
                let name = AstrologicalSignProvider.sharedInstance.order[i]
                if let sign = self.signIcons[name] {
                    sign.center = self.innerTargets[i]
                }
            }
        }
        signIconsIn.curve = .EaseOut
        
    }
    
    func taurus() -> Shape {
        let shape = AstrologicalSignProvider.sharedInstance.taurus().shape
        shape.anchorPoint = Point()
        return shape
    }
    
    func aries() -> Shape {
        let shape = AstrologicalSignProvider.sharedInstance.aries().shape
        shape.anchorPoint = Point(0.0777,0.536)
        return shape
    }
    
    func gemini() -> Shape {
        let shape = AstrologicalSignProvider.sharedInstance.gemini().shape
        shape.anchorPoint = Point(0.996,0.0)
        return shape
    }
    
    func cancer() -> Shape {
        let shape = AstrologicalSignProvider.sharedInstance.cancer().shape
        shape.anchorPoint = Point(0.0,0.275)
        return shape
    }
    
    func leo() -> Shape {
        let shape = AstrologicalSignProvider.sharedInstance.leo().shape
        shape.anchorPoint = Point(0.379,0.636)
        return shape
    }
    
    func virgo() -> Shape {
        let shape = AstrologicalSignProvider.sharedInstance.virgo().shape
        shape.anchorPoint = Point(0.750,0.387)
        return shape
    }
    
    func libra() -> Shape {
        let shape = AstrologicalSignProvider.sharedInstance.libra().shape
        shape.anchorPoint = Point(1.00,0.559)
        return shape
    }
    
    func pisces() -> Shape {
        let shape = AstrologicalSignProvider.sharedInstance.pisces().shape
        shape.anchorPoint = Point(0.099,0.004)
        return shape
    }
    
    func aquarius() -> Shape {
        let shape = AstrologicalSignProvider.sharedInstance.aquarius().shape
        shape.anchorPoint = Point(0.0,0.263)
        return shape
    }
    
    func sagittarius() -> Shape {
        let shape = AstrologicalSignProvider.sharedInstance.sagittarius().shape
        shape.anchorPoint = Point(1.0,0.349)
        return shape
    }
    
    func capricorn() -> Shape {
        let shape = AstrologicalSignProvider.sharedInstance.capricorn().shape
        shape.anchorPoint = Point(0.288,0.663)
        return shape
    }
    
    func scorpio() -> Shape {
        let shape = AstrologicalSignProvider.sharedInstance.scorpio().shape
        shape.anchorPoint = Point(0.255,0.775)
        return shape
    }
    
    
}