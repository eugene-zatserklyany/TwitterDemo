//
//  CustomNavigationController.swift
//  TwitterDemo
//
//  Created by Eugene Zatserklyaniy on 9/7/19.
//  Copyright © 2019 Eugene Zatserklyaniy. All rights reserved.
//

import UIKit

class CustomNavigationController: UINavigationController {
    
    fileprivate var interactionController: UIPercentDrivenInteractiveTransition?
    private var panGesture: UIPanGestureRecognizer!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        view.addGestureRecognizer(panGesture)
    }
    
    func shouldEnableGestures(_ state: Bool) {
        panGesture.isEnabled = state
    }
    
    @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let translate = gesture.translation(in: gesture.view)
        let percent = translate.x / gesture.view!.bounds.size.width
        
        switch gesture.state {
        case .began:
            self.interactionController = UIPercentDrivenInteractiveTransition()
            self.interactionController?.completionSpeed = 0.4
            popViewController(animated: true)
        case .changed:
            self.interactionController?.update(percent)
        case .ended:
            let velocity = gesture.velocity(in: gesture.view)
            
            if percent > 0.2 || velocity.x > 500 {
                self.interactionController?.finish()
            }
            else {
                self.interactionController?.cancel()
            }
            self.interactionController = nil
        default:
            break
        }
    }

}

extension CustomNavigationController: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if operation == .pop {
            return SystemPopAnimator(interactionController: self.interactionController)
        }
        return nil
    }
    
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactionController
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        setNavigationBarHidden(viewController.isKind(of: ProfileViewController.self), animated: animated)
    }
}

open class SystemPopAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    let interactionController: UIPercentDrivenInteractiveTransition?
    let duration: TimeInterval
    
    public init(duration: TimeInterval = 0.25,
                interactionController: UIPercentDrivenInteractiveTransition? = nil) {
        self.interactionController = interactionController
        self.duration = duration
    }
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let fromViewController = transitionContext.viewController(forKey: .from),
            let toViewController = transitionContext.viewController(forKey: .to)
            else {
                return
        }
        
        let width = fromViewController.view.frame.size.width
        let centerFrame = CGRect(x: 0, y: 0, width: width, height: fromViewController.view.frame.height)
        let completeRightFrame = CGRect(x: width, y: 0, width: width, height: fromViewController.view.frame.height)
        
        let containerView = transitionContext.containerView
       
        containerView.insertSubview(toViewController.view, belowSubview: fromViewController.view)
        
        toViewController.view.center = CGPoint(x: toViewController.view.center.x - 100, y: toViewController.view.center.y)
        
        let animations = {
//            fromViewController.view.frame = containerView.bounds.offsetBy(dx: containerView.frame.size.width, dy: 0)
//            toViewController.view.frame = containerView.bounds
            fromViewController.view.frame = completeRightFrame
            toViewController.view.frame = centerFrame

        }
        
        UIView.animate(withDuration: duration,
                       delay: 0,
                       options: [.curveEaseOut],
                       animations: animations) { _ in
                        
                        transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}
