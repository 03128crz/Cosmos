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

var gapBetweenSigns: CGFloat = 10.0

class Stars : CanvasController, UIScrollViewDelegate {
    
    let speeds : [CGFloat] = [0.08, 0.0, 0.10, 0.12, 0.15, 1.0, 0.8, 1.0]
    var scrollViews : [InfiniteScrollView]!
    var signLines: SignLines!
    var bigStars: StarsBig!
    var snapTargets: [CGFloat]!
    var scrollViewOffsetContext = 0
    
    override func setup() {
        
        canvas.backgroundColor = cosmosbkgd
        
        scrollViews = [InfiniteScrollView]()
        scrollViews.append(StarsBackground(frame: view.frame, imageName: "0Star", starCount: 20, speed: speeds[0]))
        scrollViews.append(createVignette())
        scrollViews.append(StarsBackground(frame: view.frame, imageName: "2Star", starCount: 20, speed: speeds[2]))
        scrollViews.append(StarsBackground(frame: view.frame, imageName: "3Star", starCount: 20, speed: speeds[3]))
        scrollViews.append(StarsBackground(frame: view.frame, imageName: "4Star", starCount: 20, speed: speeds[4]))
        
        signLines = SignLines(frame: view.frame)
        scrollViews.append(signLines)
        let smallStars = StarsSmall(frame: view.frame, speed: speeds[6])
        smallStars.contentOffset = CGPointMake(view.frame.size.width * CGFloat(gapBetweenSigns / 2.0), 0)
        scrollViews.append(smallStars)
        
        bigStars = StarsBig(frame: view.frame, speed: 1.0)
        bigStars.addObserver(self, forKeyPath: "contentOffset", options: .New, context: &scrollViewOffsetContext)
        bigStars.delegate = self
        bigStars.contentOffset = smallStars.contentOffset
        scrollViews.append(bigStars)
        
        for sv in scrollViews {
            canvas.add(sv)
        }
        
        createSnapTargets()
        
        bigStars.contentOffset = CGPointMake(view.frame.size.width * CGFloat(gapBetweenSigns / 2.0), 0)
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if context == &scrollViewOffsetContext {
            let sv = object as! InfiniteScrollView
            let offset = sv.contentOffset
            for i in 0..<scrollViews.count - 1 {
                let layer = scrollViews[i]
                layer.contentOffset = CGPointMake(offset.x * speeds[i], 0.0)
            }
        }
    }
    
    func createSnapTargets() {
        snapTargets = [CGFloat]()
        for i in 0...12 {
            snapTargets.append(gapBetweenSigns * CGFloat(i) * view.frame.width)
        }
    }
    
    func snapIfNeed(x: CGFloat, _ scrollView: UIScrollView) {
        for target in snapTargets {
            let dist = abs(CGFloat(target) - x)
            if dist <= CGFloat(canvas.width / 2.0) {
                scrollView.setContentOffset(CGPointMake(target, 0), animated: true)
                
                wait(0.25) {
                    var index = Int(Double(target) / (self.canvas.width * Double(gapBetweenSigns)))
                    if index == 12 {index = 0}
                    self.signLines.currentIndex = index
                    self.signLines.revealCurrentSignLines()
                }
            
                return
            }
        }
    }
    
    func goto(selection: Int) {
        let target = canvas.width * Double(gapBetweenSigns) * Double(selection)
        
        let anim = ViewAnimation(duration: 3.0) {
            self.bigStars.contentOffset = CGPoint(x: CGFloat(target), y: 0)
        }
        anim.curve = .EaseOut
        anim.addCompletionObserver() {
            self.signLines.revealCurrentSignLines()
        }
        anim.animate()
        
        signLines.currentIndex = selection
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        snapIfNeed(scrollView.contentOffset.x, scrollView)
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        self.signLines.hideCurrentSignLines()
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate == false {
            snapIfNeed(scrollView.contentOffset.x, scrollView)
        }
    }
    
    func createVignette() -> InfiniteScrollView {
        let sv = InfiniteScrollView(frame: view.frame)
        let img = Image("1vignette")!
        img.frame = canvas.frame
        sv.add(img)
        return sv
    }
}