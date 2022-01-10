//
//  UIViewController+extension.swift
//  OpenMarket
//
//  Created by Ari on 2022/01/10.
//

import UIKit

extension UIViewController {
    func showAlert(message: String) {
        let okAction = UIAlertAction(title: "OK", style: .default)
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(okAction)
        self.present(alert, animated: true)
    }
}
