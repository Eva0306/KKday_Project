//
//  ExtensionUIImage.swift
//  DiscountArea
//
//  Created by J oyce on 2024/8/23.
//

import UIKit

extension UIImageView {
    func loadImage(from url: String) {
        guard let imageURL = URL(string: url) else { return }

        URLSession.shared.dataTask(with: imageURL) { data, response, error in
            if let error = error {
                print("Failed to download image: \(error)")
                return
            }

            guard let data = data, let image = UIImage(data: data) else {
                print("Failed to convert data to image")
                return
            }

            DispatchQueue.main.async {
                self.image = image
            }
        }.resume()
    }
}

