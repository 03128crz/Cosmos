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

public class SignLines : InfiniteScrollView {
    //MARK: -
    //MARK: Properties
    //The entire set of lines, each entry is itself a set of lines
    var lines : [[Line]]!
    //The current index, used to grab the proper set of lines
    var currentIndex : Int = 0
    //Returns the current set of lines based on the current index
    var currentLines : [Line] {
        get {
            let set = lines[currentIndex]
            return set
        }
    }
    
    //MARK: -
    //MARK: Initialization
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        //grab the number of signs we're going to work with
        let count = CGFloat(AstrologicalSignProvider.sharedInstance.order.count)
        
        //calculate the content size of the entire layer, add a width to compensate for the scrollview overlap
        contentSize = CGSizeMake(frame.width * (count * gapBetweenSigns + 1), 1.0)
        
        //grab the order of the signs
        var signOrder = AstrologicalSignProvider.sharedInstance.order
        //append a copy of the first sign to the end of the order (now there will be 13)
        signOrder.append(signOrder[0])
        
        lines = [[Line]]()
        for i in 0..<signOrder.count {
            //calculate the current displacement for the sign
            let dx = Double(i) * Double(frame.width * gapBetweenSigns)
            //create a translation that considers the dx as well as positioning in vertical center of the screen
            let t = Transform.makeTranslation(Vector(x: Double(center.x) + dx, y: Double(center.y), z: 0))
            //grab the sign for the current name
            if let sign = AstrologicalSignProvider.sharedInstance.get(signOrder[i]) {
                //extract the line connections
                let connections = sign.lines
                //create a current set of lines
                var currentLineSet = [Line]()
                //iterate through the points in the current set of connections
                for points in connections {
                    //grab and transform the points
                    var begin = points[0]
                    begin.transform(t)
                    var end = points[1]
                    end.transform(t)
                    
                    //create and style a line
                    let line = Line((begin,end))
                    line.lineWidth = 1.0
                    line.strokeColor = cosmosprpl
                    line.opacity = 0.4
                    line.strokeEnd = 0.0
                    
                    //add the line to the canvas and to the current line set
                    add(line)
                    currentLineSet.append(line)
                }
                //append the current set to the lines array
                lines.append(currentLineSet)
            }
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //MARK: -
    //MARK: Animations
    func revealCurrentSignLines() {
        ViewAnimation(duration: 0.25) {
            for line in self.currentLines {
                line.strokeEnd = 1.0
            }
            }.animate()
    }
    
    func hideCurrentSignLines() {
        ViewAnimation(duration: 0.25) {
            for line in self.currentLines {
                line.strokeEnd = 0.0
            }
            }.animate()
    }
}