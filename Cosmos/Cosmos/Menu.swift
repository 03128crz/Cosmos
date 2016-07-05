// Copyright © 2015 
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

typealias SelectionAction = (selection: Int) -> Void
typealias InfoAction = () -> Void

class Menu : CanvasController {
    
    var menuRings: MenuRings!
    var menuIcons: MenuIcons!
    var menuSelector: MenuSelector!
    var menuShadow: MenuShadow!
    
    var shouldRevert = false
    var menuIsVisible = false
    
    let hideMenuSound = AudioPlayer("menuClose.mp3")!
    let revealMenuSound = AudioPlayer("menuOpen.mp3")!
    
    var instructionLabel: UILabel!
    var timer: Timer!
    
    var selectionAction : SelectionAction?
    var infoAction : InfoAction?
    
    override func setup() {
        canvas.backgroundColor = clear
        canvas.frame = Rect(0,0,80,80)
        
        menuRings = MenuRings()
        menuSelector = MenuSelector()
        menuIcons = MenuIcons()
        menuShadow = MenuShadow()
        menuShadow.canvas.center = canvas.bounds.center
        
        canvas.add(menuShadow?.canvas)
        canvas.add(menuRings?.canvas)
        canvas.add(menuSelector?.canvas)
        canvas.add(menuIcons?.canvas)
        
        hideMenuSound.volume = 0.64
        revealMenuSound.volume = 0.64
        
        createGesture()
        createInstructionLabel()
        
        timer = Timer(interval: 5.0, count: 1) {
            self.showInstruction()
        }
        timer.start()
    }
    
    func createGesture() {
        canvas.addLongPressGestureRecognizer { (locations, center, state) in
            switch state {
            case . Began:
                self.revealMenu()
            case .Changed:
                self.menuSelector.update(center)
            case .Cancelled, .Ended, .Failed:
                
                if let sa = self.selectionAction where self.menuSelector.currentSelection >= 0 {
                    sa(selection: self.menuSelector.currentSelection)
                }
                
                self.menuSelector.currentSelection = -1
                self.menuSelector.menuLabel.hidden = true
                self.canvas.interactionEnabled = false
                
                if self.menuSelector.highlight.hidden == false {
                    self.menuSelector.highlight.hidden = true
                }
                
                if let ib = self.menuSelector.infoButton {
                    if ib.hitTest(center, from: self.canvas) {
                        if let  ia = self.infoAction {
                            wait(0.75) {
                                ia()
                            }
                        }
                    }
                }
                
                
                if self.menuIsVisible {
                    self.hideMenu()
                } else {
                    self.shouldRevert = true
                }
            default:
                _ = ""
            }
        }
    }
    
    func createInstructionLabel() {
        instructionLabel = UILabel(frame: CGRect(x: 0,y: 0,width: 320, height: 44))
        instructionLabel.text = "press and hold to open menu\nthen drag to choose a sign"
        instructionLabel.font = UIFont(name: "Menlo-Regular", size: 13)
        instructionLabel.textAlignment = .Center
        instructionLabel.textColor = .whiteColor()
        instructionLabel.userInteractionEnabled = false
        instructionLabel.center = CGPointMake(view.center.x,view.center.y - 128)
        instructionLabel.numberOfLines = 2
        instructionLabel.alpha = 0.0
        canvas.add(instructionLabel)
    }
    
    func showInstruction() {
        ViewAnimation( duration: 2.5) {
            self.instructionLabel.alpha = 1.0
            }.animate()
    }
    
    func hideInstruction() {
        ViewAnimation( duration: 0.25) {
            self.instructionLabel.alpha = 0.0
        }.animate()
    }
    
    func revealMenu() {
        
        timer.stop()
        hideInstruction()
        
        revealMenuSound.play()
        self.menuIsVisible = false
        
        menuShadow.reveal?.animate()
        menuRings.thickRingOut?.animate()
        menuRings.thinRingOut?.animate()
        menuIcons.signIconsOut.animate()
        
        wait(0.33) {
            self.menuRings.revealHideDividingLines(1.0)
            self.menuIcons.revealSignIcons.animate()
        }
        
        wait(0.66) {
            self.menuRings.revealDashedRings?.animate()
            self.menuSelector.revealInfoButton?.animate()
        }
        
        wait(1.0) {
            self.menuIsVisible = true
            
            if self.shouldRevert {
                self.hideMenu()
                self.shouldRevert = false
            }
        }
    }
    
    func hideMenu() {
        
        if instructionLabel.alpha > 0.0 {
            hideInstruction()
        }
        
        hideMenuSound.play()
        self.menuIsVisible = false
        
        menuRings.hideDashedRings?.animate()
        menuSelector.hideInfoButton?.animate()
        menuRings.revealHideDividingLines(0.0)
        
        wait(0.16) {
            self.menuIcons.hideSignIcons.animate()
        }
        
        wait(0.57) {
            self.menuRings.thinRingIn?.animate()
        }
        
        wait(0.66) {
            self.menuShadow.hide?.animate()
            self.menuIcons.signIconsIn.animate()
            self.menuRings.thickRingIn?.animate()
            self.menuShadow.hide?.animate()
            self.canvas.interactionEnabled = true
        }
        
    }
}