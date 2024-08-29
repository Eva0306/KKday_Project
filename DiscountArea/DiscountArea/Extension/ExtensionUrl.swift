//
//  ExtensionUrl.swift
//  DiscountArea
//
//  Created by J oyce on 2024/8/28.
//

import Foundation
import UIKit
import WebKit

func open(urlString: String) {
    guard let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) else {
        print("Invalid URL or cannot open URL")
        return
    }
    UIApplication.shared.open(url, options: [:], completionHandler: nil)
}
