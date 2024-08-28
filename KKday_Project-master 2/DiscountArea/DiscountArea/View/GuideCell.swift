//
//  guideCell.swift
//  DiscountArea
//
//  Created by J oyce on 2024/8/23.
//

import UIKit

class guideCell: UICollectionViewCell {

    let imageView = UIImageView()
    let heartImageView = UIImageView(image: UIImage(named: "ic-card-wish-normal"))

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        imageView.layer.cornerRadius = 10
        imageView.translatesAutoresizingMaskIntoConstraints = false
        heartImageView.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(imageView)
        contentView.addSubview(heartImageView)

        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            //imageView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.3),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
            imageView.heightAnchor.constraint(equalToConstant: 204),

            heartImageView.topAnchor.constraint(equalTo: imageView.topAnchor, constant: 10),
            heartImageView.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: -10),
            heartImageView.widthAnchor.constraint(equalToConstant: 30),
            heartImageView.heightAnchor.constraint(equalToConstant: 30)
        ])
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = UIImage(named: "placeHolder")
        imageView.layer.cornerRadius = 10
    }
}
