//
// Copyright © 2017 Handsome.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
/////////////////////////////////////////////////////////////////////////////

import UIKit

class ConfirmationAnimatedView : UIView {
    
    typealias Action = () -> ()
    var didFinish: Action?

    init(color: UIColor) {
        super.init(frame: CGRect.zero)
        
        dotView = DotView(color: color)
        dotView.isHidden = true
        addSubview(dotView)
        
        first = createLineView(rising: false)
        second = createLineView(rising: true)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showConfirmation(startPoint: CGPoint) {
        dotView.center = startPoint
        dotView.isHidden = false
        
        first.alpha = 1
        second.alpha = 1

        let springParameters = UISpringTimingParameters(mass: 2.2, stiffness: 300, damping: 30, initialVelocity: CGVector(dx: 0, dy: 0))

        let springAnimator = UIViewPropertyAnimator(duration: 0.0, timingParameters: springParameters)
        springAnimator.addAnimations {
            self.dotView.frame = CGRect(x: startPoint.x - self.kConfirmationFinalSize / 2, y: startPoint.y - self.kConfirmationFinalSize / 2, width: self.kConfirmationFinalSize, height: self.kConfirmationFinalSize)
        }
        springAnimator.startAnimation()
        showCorrectMark(startPoint: startPoint)
    }

    func dotViewCenter() -> CGPoint {
        return dotView.center
    }

    func moveDotView(to: CGPoint) {
        self.dotView.center = to
    }

    
    /////////////////////////////////////////////////////////////////////////
    //
    // MARK: - Private
    //

    private let kConfirmationFinalSize: CGFloat = 60
    private let kConfirmationOffsetHeight: CGFloat = 30

    private var first: LineView!
    private var second: LineView!

    private var dotView : DotView!

    private let controlPoint1 = CGPoint(x: 0.25, y: 0.1)
    private let controlPoint2 = CGPoint(x: 0.25, y: 1)

    private func showCorrectMark(startPoint: CGPoint) {
        let smallMarkSize = CGFloat(10)
        let bigMarkSize = CGFloat(20)
        self.first.frame = CGRect(x: startPoint.x - 12, y: startPoint.y, width: 0, height: 0)
        self.second.frame = CGRect(x: startPoint.x - 3, y: startPoint.y + smallMarkSize, width: 0, height: 0)

        let firstLineAnimator = UIViewPropertyAnimator(duration: 0.43, controlPoint1: self.controlPoint1, controlPoint2: self.controlPoint2)
        
        firstLineAnimator.addAnimations({
            self.first.frame = CGRect(x: self.first.frame.origin.x, y: self.first.frame.origin.y, width: smallMarkSize + 1, height: smallMarkSize)
            self.first.setNeedsDisplay()
        }, delayFactor: 0.7)

        firstLineAnimator.addCompletion { _ in
            self.second.isHidden = false

            let secondLineAnimator = UIViewPropertyAnimator(duration: 0.13, controlPoint1: self.controlPoint1, controlPoint2: self.controlPoint2, animations: {
                self.second.frame = CGRect(x: self.second.frame.origin.x - 2, y: self.second.frame.origin.y - bigMarkSize, width: bigMarkSize, height: bigMarkSize)
                self.second.setNeedsDisplay()
            })
            secondLineAnimator.addCompletion { _ in
                self.finish()
            }
            secondLineAnimator.startAnimation()
        }
        firstLineAnimator.startAnimation()
    }
    
    private func createLineView(rising : Bool) -> LineView {
        let lineView = LineView(color: UIColor.white)
        lineView.frame = CGRect.zero
        lineView.alpha = 0
        lineView.rising = rising
        addSubview(lineView)
        return lineView
    }

    private func finish() {
        let finishConfirmationAnimator = UIViewPropertyAnimator(duration: 1.1, controlPoint1: self.controlPoint1, controlPoint2: self.controlPoint2)

        finishConfirmationAnimator.addAnimations({

            let center = self.dotView.center
            self.first.alpha = 0
            self.second.alpha = 0
            self.first.frame = CGRect(x: center.x, y: center.y - self.kConfirmationOffsetHeight, width: 0, height: 0)
            self.second.frame = CGRect(x: center.x, y: center.y - self.kConfirmationOffsetHeight, width: 0, height: 0)
            self.dotView.frame = CGRect(x: center.x - kDotSize / 2, y: center.y - kDotSize / 2 - self.kConfirmationOffsetHeight, width: kDotSize, height: kDotSize)
        }, delayFactor: 0.8)

        finishConfirmationAnimator.addCompletion { _ in
            self.didFinish?()
        }
        finishConfirmationAnimator.startAnimation()
    }
}

class LineView : UIView {

    private let lineWidth: CGFloat = 2.5

    private var color: UIColor
    
    init(color: UIColor) {
        self.color = color
        super.init(frame: CGRect.zero)
        backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var rising = false
    
    override func draw(_ rect: CGRect) {
        let path = UIBezierPath()
        path.lineWidth = lineWidth
        path.lineCapStyle = .round
        path.lineJoinStyle = .round
        if rising {
            path.move(to: CGPoint(x: lineWidth / 2 + 1, y: rect.height - lineWidth / 2 - 1))
            path.addLine(to: CGPoint(x: rect.width - lineWidth / 2 - 1, y: lineWidth / 2 + 1))
        } else {
            path.move(to: CGPoint(x: lineWidth / 2 + 1, y: lineWidth / 2 + 1))
            path.addLine(to: CGPoint(x: rect.width - lineWidth / 2 - 1, y: rect.height - lineWidth / 2 - 1))
        }
        color.setStroke()
        path.stroke()
    }
}
