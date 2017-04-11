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

class ViewController: UIViewController {
    
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var fakeButtonView: UIView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var logoImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        progressLabel.alpha = 0.0
        setupDotView(dotView: dotViewLeft)
        setupDotView(dotView: dotViewCenter)
        setupDotView(dotView: dotViewRight)
        fakeButtonView.clipsToBounds = true
    }
    
    @IBAction func startAnimationTapped(_ sender: AnyObject) {
        animateJumpUp()
    }

    /////////////////////////////////////////////////////////////////////////
    //
    // MARK: - Private
    //

    private let kAnimationHeight: CGFloat = 24
    private let kDotsJumpsCountMax = 5
    private let kInitialCenterOffset: CGFloat = 40

    private let controlPoint1 = CGPoint(x: 0.25, y: 0.1)
    private let controlPoint2 = CGPoint(x: 0.25, y: 1)

    private let dotViewLeft = DotView(color: UIColor.appBrandColor())
    private let dotViewCenter = DotView(color: UIColor.appBrandColor())
    private let dotViewRight = DotView(color: UIColor.appBrandColor())

    private var dotsUpAnimator: [UIViewPropertyAnimator] = []
    private var timer: Timer?
    private var toTop = true
    private var buttonCenter: CGPoint!

    private var dotsJumpsCount = 0
    
    private func animateJumpUp() {
        self.buttonCenter = fakeButtonView.center
        self.startButton.alpha = 0
        let animator = UIViewPropertyAnimator(duration: 0.3, controlPoint1: controlPoint1, controlPoint2: controlPoint2, animations: {
            self.fakeButtonView.frame = CGRect(x: 0, y: 0, width: kDotSize, height: kDotSize)
            self.fakeButtonView.center = self.buttonCenter
            self.fakeButtonView.layer.cornerRadius = 7.0
            self.descriptionLabel.alpha = 0
            self.logoImageView.alpha = 0
        })
        
        let velocity = CGVector(dx: 0, dy: 0)
        let springParameters = UISpringTimingParameters(mass: 1.8, stiffness: 330, damping: 33, initialVelocity: velocity)
        
        let springAnimator = UIViewPropertyAnimator(duration: 0.0, timingParameters: springParameters)
        springAnimator.addAnimations ({
            self.fakeButtonView.center.y = self.dotViewCenter.center.y
        }, delayFactor: 0.3)
        springAnimator.addCompletion { _ in
            self.fakeButtonView.isHidden = true
            self.dotViewLeft.isHidden = false
            self.dotViewCenter.isHidden = false
            self.dotViewRight.isHidden = false
            self.createHorizontalDotsAnimation(isForward: true)
        }
        animator.startAnimation()
        springAnimator.startAnimation()
    }
    
    private func createHorizontalDotsAnimation(isForward: Bool) {
        let animator = UIViewPropertyAnimator(duration: 0.3, controlPoint1: controlPoint1, controlPoint2: controlPoint2, animations: {
            self.progressLabel.center.y = isForward ? self.progressLabel.center.y - 60 :
                self.progressLabel.center.y + 60
            self.progressLabel.alpha = isForward ? 1.0 : 0.0
            self.dotViewLeft.center.x = isForward ? self.view.center.x - self.dotViewLeft.frame.width * 1.8 : self.view.center.x
            self.dotViewRight.center.x = isForward ? self.view.center.x + self.dotViewLeft.frame.width * 1.8 : self.view.center.x
        })
        if isForward {
            animator.addCompletion { _ in
                self.timer = Timer.scheduledTimer(timeInterval: 0.53, target: self, selector: #selector(self.startReversedDotsAnimation), userInfo: nil, repeats: true)
                self.createDotsAnimation()
                for dotAnimator in self.dotsUpAnimator {
                    dotAnimator.startAnimation()
                }
            }
        } else {
            animator.addCompletion({ _ in
                self.dotViewLeft.isHidden = true
                self.dotViewCenter.isHidden = true
                self.dotViewRight.isHidden = true

                let confirmationAnimatedView = ConfirmationAnimatedView(color: UIColor.appBrandColor())
                self.view.addSubview(confirmationAnimatedView)
                confirmationAnimatedView.didFinish = {
                        self.fakeButtonView.frame = CGRect(x: 0, y: 0, width: kDotSize, height: kDotSize)
                        self.fakeButtonView.center = confirmationAnimatedView.dotViewCenter()
                        confirmationAnimatedView.removeFromSuperview()
                        self.animateJumpDown()
                    }
                confirmationAnimatedView.showConfirmation(startPoint: CGPoint(x: self.view.center.x, y: self.view.center.y - self.kInitialCenterOffset))
            })
        }
        animator.startAnimation()
    }
    
    private func createDotsAnimation() {
        let dotLeftAnimator = UIViewPropertyAnimator(duration: 0.37, controlPoint1: controlPoint1, controlPoint2: controlPoint2, animations: {
            self.dotViewLeft.center.y = self.dotViewLeft.center.y - self.kAnimationHeight
        })
        dotsUpAnimator.append(dotLeftAnimator)
        
        let dotCenterAnimator = UIViewPropertyAnimator(duration: 0.43, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
        dotCenterAnimator.addAnimations ({
            self.dotViewCenter.center.y = self.dotViewCenter.center.y - self.kAnimationHeight
        }, delayFactor: 0.2)
        
        dotsUpAnimator.append(dotCenterAnimator)
        
        let dotRightAnimator = UIViewPropertyAnimator(duration: 0.53, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
        dotRightAnimator.addAnimations ({
            self.dotViewRight.center.y = self.dotViewRight.center.y - self.kAnimationHeight
        }, delayFactor: 0.32)
        
        dotsUpAnimator.append(dotRightAnimator)
    }
    
    @objc private func startReversedDotsAnimation() {
        if dotsJumpsCount < kDotsJumpsCountMax {

            dotsJumpsCount += 1
            toTop = !toTop
            
            dotsUpAnimator[0].addAnimations ({
                self.dotViewLeft.center.y = self.toTop ? self.dotViewLeft.center.y - self.kAnimationHeight : self.dotViewLeft.center.y + self.kAnimationHeight
            })
            
            dotsUpAnimator[1].addAnimations ({
                self.dotViewCenter.center.y = self.toTop ? self.dotViewCenter.center.y - self.kAnimationHeight : self.dotViewCenter.center.y + self.kAnimationHeight
                }, delayFactor: 0.2)
            
            dotsUpAnimator[2].addAnimations ({
                self.dotViewRight.center.y = self.toTop ? self.dotViewRight.center.y - self.kAnimationHeight : self.dotViewRight.center.y + self.kAnimationHeight
                }, delayFactor: 0.32)

            // Add complition action after finishing jumping of third dot
            //
            if dotsJumpsCount == kDotsJumpsCountMax {
                dotsUpAnimator[2].addCompletion { _ in
                    self.createHorizontalDotsAnimation(isForward: false)
                    self.dotsUpAnimator.removeAll()
                    self.toTop = true
                }
                dotsJumpsCount = 0
                finishDotsProgressAnimation()
            }
            
            for dotAnimator in dotsUpAnimator {
                dotAnimator.startAnimation()
            }
        }
    }
    
    private func animateJumpDown() {
        self.descriptionLabel.center.y += 50
        self.logoImageView.center.y += 50
        let showContentAnimator = UIViewPropertyAnimator(duration: 0.5, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
        showContentAnimator.addAnimations({ _ in
            self.descriptionLabel.alpha = 1
            self.logoImageView.alpha = 1
            self.descriptionLabel.center.y -= 50
            self.logoImageView.center.y -= 50
            self.fakeButtonView.frame = self.startButton.frame
        }, delayFactor: 0.43)

        showContentAnimator.addCompletion { _ in
            self.fakeButtonView.layer.cornerRadius = 0.0
        }

        self.fakeButtonView.isHidden = false
        self.fakeButtonView.layer.cornerRadius = 7.0
        self.fakeButtonView.clipsToBounds = true
        showContentAnimator.addCompletion { _ in
            self.fakeButtonView.layer.cornerRadius = 0.0
        }

        let showButtonTextAnimator = UIViewPropertyAnimator(duration: 0.3, controlPoint1: controlPoint1, controlPoint2: controlPoint2, animations: {
            self.startButton.alpha = 1
        })
        showButtonTextAnimator.addCompletion { _ in
            let radiusFakeButtonAnimator = UIViewPropertyAnimator(duration: 0.3, controlPoint1: self.controlPoint1, controlPoint2: self.controlPoint2, animations: {
                self.fakeButtonView.layer.cornerRadius = 0.0
            })
            radiusFakeButtonAnimator.startAnimation()
        }

        let animatorJumpDown = UIViewPropertyAnimator(duration: 0.29, controlPoint1: CGPoint(x: 0.68, y: 0), controlPoint2: CGPoint(x: 0.53, y: 1.3), animations: {
            self.fakeButtonView.center = self.startButton.center
        })
        animatorJumpDown.addCompletion { _ in
            showButtonTextAnimator.startAnimation()
        }

        animatorJumpDown.startAnimation()
        showContentAnimator.startAnimation()
    }
    
    private func finishDotsProgressAnimation() {
        timer?.invalidate()
        timer = nil
    }
    
    private func setupDotView(dotView: DotView) {
        dotView.center = centerPoint()
        dotView.isHidden = true
        view.addSubview(dotView)
    }
    
    private func centerPoint() -> CGPoint {
        return CGPoint(x: self.view.center.x, y: self.view.center.y - kInitialCenterOffset)
    }
}

