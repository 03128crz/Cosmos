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

public class MenuSelector : CanvasController {
    
    var highlight: Shape!
    var currentSelection = -1
    var menuLabel: TextShape!
    var infoButton: View!
    
    var revealInfoButton: ViewAnimation?
    var hideInfoButton: ViewAnimation?
    
    let tick = AudioPlayer("tick.mp3")!
    
    public override func setup() {
        canvas.frame = Rect(0,0,80,80)
        canvas.backgroundColor = clear
        createHighlight()
        createLabel()
        createInfoButton()
        createInfoButtonAnimations()
        tick.volume = 0.4
    }
    
    func createLabel() {
        let f = Font(name: "Menlo-Regular", size: 13)!
        menuLabel = TextShape(text: "COSMOS", font: f)!
        menuLabel.center = canvas.center
        menuLabel.fillColor = white
        menuLabel.interactionEnabled = false
        canvas.add(menuLabel)
        menuLabel.hidden = true
    }
    
    func createInfoButton() {
        infoButton = View(frame: Rect(0,0,44,44))
        let buttonImage = Image("info")
        buttonImage?.interactionEnabled = false
        buttonImage?.center = infoButton.center
        infoButton.add(buttonImage)
        infoButton.opacity = 0.0
        infoButton.center = Point(canvas.center.x, canvas.center.y + 190.0)
        canvas.add(infoButton)
    }
    
    func update(location: Point) {
        
        let dist = distance(location, rhs: self.canvas.bounds.center)
        
        if dist > 102 && dist < 156 {
            highlight.hidden = false
            
            let a = Vector(x: self.canvas.width / 2.0 + 1.0, y: self.canvas.height / 2.0)
            let b = Vector(x: self.canvas.width / 2.0, y: self.canvas.height / 2.0)
            let c = Vector(x: location.x, y: location.y)
            
            var ϴ = c.angleTo(a, basedOn: b)
            if c.y < a.y {
                ϴ = 2 * M_PI - ϴ
            }
            
            menuLabel.hidden = false
            
            let index = Int(radToDeg(ϴ)) / 30

            if currentSelection != index {
                tick.stop()
                tick.play()
                
                ShapeLayer.disableActions = true
                menuLabel.text = AstrologicalSignProvider.sharedInstance.order[index].capitalizedString
                menuLabel.center = canvas.bounds.center
                ShapeLayer.disableActions = false
                
                currentSelection = index
                let rotation = Transform.makeRotation(degToRad(Double(index) * 30.0), axis: Vector(x: 0, y: 0, z: -1))
                highlight.transform = rotation
            }
        } else {
            menuLabel.hidden = true
            highlight.hidden = true
            currentSelection = -1
            
            if let l = infoButton {
                if l.hitTest(location, from: canvas) {
                    menuLabel.hidden = false
                    ShapeLayer.disableActions = true
                    menuLabel.text = "Info"
                    menuLabel.center = canvas.bounds.center
                    ShapeLayer.disableActions = false
                }
            }
        }
    }
    
    func createHighlight() {
        highlight = Wedge(center: canvas.center, radius: 156, start: M_PI / 6.0, end: 0.0, clockwise: false)
        highlight.fillColor = cosmosblue
        highlight.lineWidth = 0.0
        highlight.opacity = 0.8
        highlight.interactionEnabled = false
        highlight.anchorPoint = Point()
        highlight.center = canvas.center
        highlight.hidden = true
        
        let donut  = Circle(center: highlight.center, radius: 156 - 54 / 2.0)
        donut.fillColor = clear
        donut.lineWidth = 54
        highlight.mask = donut
        
        canvas.add(highlight)
    }
    
    func createInfoButtonAnimations() {
        revealInfoButton = ViewAnimation(duration: 0.33) {
            self.infoButton.opacity = 1.0
        }
        revealInfoButton?.curve = .EaseOut

        hideInfoButton = ViewAnimation(duration: 0.33) {
            self.infoButton.opacity = 0.0
        }
        hideInfoButton?.curve = .EaseOut
    }
}