//
//  UIViewController+Alert.swift
//  MyMovies
//
//  Created by Suresh on 09/05/21.
//

import Foundation
import UIKit

extension UIViewController {
    func alertUser(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
}
