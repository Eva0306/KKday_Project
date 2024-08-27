//
//  ExtensionUIImageView.swift
//  DiscountArea
//
//  Created by Nicky Y on 2024/8/26.
//

import UIKit

extension UIImageView {

    func loadImage(from url: URL) {

        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in

            guard let self = self, let data = data, error == nil else {
                print("Error fetching image: (String(describing: error))")
                return
            }

            if let downloadedImage = UIImage(data: data) {

                DispatchQueue.main.async {
                    self.image = downloadedImage
                }
            }
        }
        task.resume()
    }
}
