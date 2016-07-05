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

public class StarsBig : InfiniteScrollView {
    
    convenience public init(frame: CGRect, speed: CGFloat) {
        self.init(frame: frame)
        
        var signOrder = AstrologicalSignProvider.sharedInstance.order
        contentSize = CGSizeMake(frame.size.width * (1.0 + CGFloat(signOrder.count) * gapBetweenSigns), 1.0)
        signOrder.append(signOrder[0])
        
        for i in 0..<signOrder.count {
            let dx = Double(i) * Double(frame.size.width * speed * gapBetweenSigns)
            
            let t = Transform.makeTranslation(Vector(x: Double(center.x) + dx, y: Double(center.y), z: 0))
            if let sign = AstrologicalSignProvider.sharedInstance.get(signOrder[i]) {
                for point in sign.big {
                    let img = Image("7bigStar")!
                    var p = point
                    p.transform(t)
                    img.center = p
                    add(img)
                }
            }
        }
        
        addDashes()
        addMarkers()
        addSignNames()
    }
    
    func addDashes() {
        let points = (Point(0, Double(frame.maxY)), Point(Double(contentSize.width), Double(frame.maxY)))
        let dashes = Line(points)
        dashes.lineDashPattern = [2,2]
        dashes.lineWidth = 10
        dashes.strokeColor = cosmosblue
        dashes.opacity = 0.33
        dashes.lineCap = .Butt
        add(dashes)
    }

    func addMarkers() {
        for i in 0..<AstrologicalSignProvider.sharedInstance.order.count + 1 {
            let dx = Double(i) * Double(frame.width * gapBetweenSigns) + Double(frame.width / 2.0)
            
            let begin = Point(dx, Double(frame.height - 20.0))
            let end = Point(dx, Double(frame.height))
            
            let marker = Line((begin, end))
            marker.lineWidth = 2
            marker.strokeColor = white
            marker.lineCap = .Butt
            marker.opacity = 0.33
            add(marker)
        }
    }
    
    func addSignNames() {
        //grabs the sign names
        var signNames = AstrologicalSignProvider.sharedInstance.order
        //appends a copy of the first name to the end of the array
        signNames.append(signNames[0])
        
        //specify the y position of the sign
        let y = Double(frame.size.height - 86.0)
        //calculate the displacement to the current frame
        let dx = Double(frame.size.width * gapBetweenSigns)
        //define the offset to the center of the canvas
        let offset = Double(frame.size.width / 2.0)
        //create a font
        let font = Font(name:"Menlo-Regular", size: 13.0)!
        
        //for each of the names
        for i in 0..<signNames.count {
            //grab the current
            let name = signNames[i]
            
            //calculate the point for the sign
            var point = Point(offset + dx * Double(i),y)
            //grab the current sign (based on the name), add it to the view
            if let sign = self.createSmallSign(name) {
                sign.center = point
                add(sign)
            }
            
            //offset y by a bit
            point.y += 26.0
            
            //add a label for the current name
            let title = self.createSmallSignTitle(name, font: font)
            title.center = point
            
            //offset y by a little bit
            point.y+=22.0
            
            //calculate the current degrees
            var value = i * 30
            //if it is > 330, make it 0 so the the overlap is consistent with the first sign's label
            if value > 330 { value = 0 }
            //create a label for the degrees
            let degree = self.createSmallSignDegree(value, font: font)
            degree.center = point
            
            add(title)
            add(degree)
        }
    }
    
    func createSmallSign(name: String) -> Shape? {
        var smallSign : Shape?
        //try to extract a sign from the provider, and style it
        if let sign = AstrologicalSignProvider.sharedInstance.get(name)?.shape {
            sign.lineWidth = 2
            sign.strokeColor = white
            sign.fillColor = clear
            sign.opacity = 0.33
            //scale the sign down from its original size
            sign.transform = Transform.makeScale(0.66, 0.66, 0)
            smallSign = sign
        }
        return smallSign
    }
    
    //create a text shape from a name and a font
    func createSmallSignTitle(name: String, font: Font) -> TextShape {
        let text = TextShape(text:name, font:font)!
        text.fillColor = white
        text.lineWidth = 0
        text.opacity = 0.33
        return text
    }
    
    func createSmallSignDegree(degree: Int, font: Font) -> TextShape {
        //return a string with a little degree symbol
        return createSmallSignTitle("\(degree)°", font: font)
    }

}