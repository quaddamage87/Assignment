//
//  UIViewController+Spinner.swift
//  Assignment
//
//  Created by Martijn Breet on 21/03/2020.
//  Copyright © 2020 Martijn Breet. All rights reserved.
//

import Foundation
import UIKit

fileprivate var overlayView : UIView?

extension UIViewController {
    
    func showSpinner(on targetView : UIView) {
        
        overlayView = UIView(frame: targetView.frame)
        overlayView?.backgroundColor = .white
        let activityIndicator = UIActivityIndicatorView(style: .gray)
        activityIndicator.center = overlayView!.center
        activityIndicator.startAnimating()
        overlayView?.addSubview(activityIndicator)
        view.addSubview(overlayView!)
    }
    
    func removeSpinner() {
        overlayView?.removeFromSuperview()
        overlayView = nil
    }
    
    func showAlert(with message: String) {
        let alertController = UIAlertController(title: "Error", message:
            message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default))

        self.present(alertController, animated: true, completion: nil)
    }
}
