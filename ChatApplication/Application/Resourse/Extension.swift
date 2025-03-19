//
//  Extension.swift
//  ChatApplication
//
//  Created by Anupam on 18/03/25.
//

import Foundation
import UIKit

extension UIView {
	// MARK: - Properties
	public var width: CGFloat {
		return self.frame.size.width
	}
	
	public var height: CGFloat {
		return self.frame.size.height
	}
	
	public var top: CGFloat {
		return self.frame.origin.y
	}
	
	public var bottom: CGFloat {
		return self.frame.size.height + self.frame.origin.y
	}
	
	public var left: CGFloat {
		return self.frame.origin.x
	}
	
	public var right: CGFloat {
		return self.frame.origin.x + self.frame.size.width
	}
}

extension UIViewController {
	func showAlert(
		alertText : String,
		alertMessage : String
	) {
		let alert = UIAlertController(
			title: alertText,
			message: alertMessage,
			preferredStyle: UIAlertController.Style.alert
		)
		alert
			.addAction(
				UIAlertAction(
					title: "Got it",
					style: UIAlertAction.Style.default,
					handler: nil
				)
			)
		self.present(
			alert,
			animated: true,
			completion: nil
		)
	}
}
