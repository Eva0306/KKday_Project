//
//  promoProductCell.swift
//  DiscountArea
//
//  Created by J oyce on 2024/8/23.
//

import UIKit

class promoProductCell: UICollectionViewCell {

    let imageView = UIImageView()
    let starImage = UIImageView()
    let name = UILabel()
    let star = UILabel()
    let price = UILabel()

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
        name.translatesAutoresizingMaskIntoConstraints = false
        starImage.image = UIImage(named: "star")
        starImage.translatesAutoresizingMaskIntoConstraints = false
        star.translatesAutoresizingMaskIntoConstraints = false
        price.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(imageView)
        contentView.addSubview(name)
        contentView.addSubview(starImage)
        contentView.addSubview(star)
        contentView.addSubview(price)

        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true

        name.textAlignment = .left
        star.textAlignment = .left
        price.textAlignment = .left

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            imageView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.3),

            name.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            name.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            name.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),

            starImage.topAnchor.constraint(equalTo: name.bottomAnchor, constant: 8),
            starImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            starImage.heightAnchor.constraint(equalToConstant: 18),
            starImage.widthAnchor.constraint(equalToConstant: 18),

            star.topAnchor.constraint(equalTo: name.bottomAnchor, constant: 8),
            star.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40),
            star.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),

            price.topAnchor.constraint(equalTo: star.bottomAnchor, constant: 8),
            price.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            price.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24)
        ])
    }

    func configure(labelTexts: [String]) {
//        imageView.backgroundColor = imageName
        
        name.text = labelTexts[0]
        star.text = labelTexts[1]
        price.text = labelTexts[2]
    }
}
