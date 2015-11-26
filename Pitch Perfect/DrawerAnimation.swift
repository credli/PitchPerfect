//
//  DrawerAnimation.swift
//  Pitch Perfect
//
//  Created by Nicholas Credli on 11/26/15.
//  Copyright © 2015 Novium Collective SARL. All rights reserved.
//

import UIKit

class DrawerAnimation : NSObject {
    let duration = 0.80
    let drawerOffset: CGFloat = 100
    let defaultSpringDampingValue: CGFloat = 0.7
    let defaultSpringVelocityValue: CGFloat = 0.3
    var presenting: Bool = false
}

extension DrawerAnimation : UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return presenting ? duration : duration / 2
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        let containerView = transitionContext.containerView()!
        
        let springDamping: CGFloat = presenting ? defaultSpringDampingValue : 1.0
        let springVelocity: CGFloat = presenting ? defaultSpringVelocityValue : 1.0
        
        
        containerView.backgroundColor = UIColor.whiteColor()
        containerView.addSubview(fromVC.view)
        containerView.addSubview(toVC.view)
        
        if presenting == true {
            fromVC.view.frame = CGRectMake(0, 0, containerView.frame.width, containerView.frame.height)
            toVC.view.frame = CGRectMake(0, containerView.frame.height, containerView.frame.width, containerView.frame.height - drawerOffset)
            toVC.view.alpha = 0
        } else {
            toVC.view.frame = CGRectMake(0, drawerOffset - toVC.view.frame.size.height, containerView.frame.width, containerView.frame.height)
            fromVC.view.frame = CGRectMake(0, drawerOffset, containerView.frame.width, containerView.frame.height - drawerOffset)
        }
        
        UIView.animateWithDuration(transitionDuration(transitionContext), delay: 0.0, usingSpringWithDamping: springDamping, initialSpringVelocity: springVelocity, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            
            if self.presenting == true {
                toVC.view.frame = CGRectMake(0, self.drawerOffset, containerView.frame.width, containerView.frame.height - self.drawerOffset)
                toVC.view.alpha = 1
                fromVC.view.frame = CGRectMake(0, self.drawerOffset - fromVC.view.frame.size.height, containerView.frame.width, containerView.frame.height)
            } else {
                fromVC.view.frame = CGRectMake(0, containerView.frame.height, containerView.frame.width, containerView.frame.height - self.drawerOffset)
                fromVC.view.alpha = 0
                toVC.view.frame = CGRectMake(0, 0, containerView.frame.width, containerView.frame.height)
            }
            
        }) {
            _ in
            transitionContext.completeTransition(true)
            
            //This corrects an iOS 8/9 bug where the toVC would disappear after the transition end
            //http://stackoverflow.com/questions/24338700/from-view-controller-disappears-using-uiviewcontrollercontexttransitioning
            if !self.presenting {
                UIApplication.sharedApplication().keyWindow!.addSubview(toVC.view)
            }
        }
    }
}