//
//  GuideContainerCell.swift
//  DiscountArea
//
//  Created by J oyce on 2024/8/27.
//

import Foundation
import UIKit

class GuideContainerCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var httpRequestManager = HTTPRequestManager()

    var guideList: [Guide] = [] {
        didSet{
            guideCollectionView.reloadData()
            guideCollectionView.layoutIfNeeded()
        }
    }
    
    var backgroundImageView = UIImageView()

    var guideCollectionView: UICollectionView!

    let cellIdentifier = "guideCell"

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupBackground()
        setUpGuideCollectionView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupBackground() {
        backgroundImageView.image = UIImage(named: "guide_background")
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(backgroundImageView)
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            backgroundImageView.heightAnchor.constraint(equalToConstant: 380)
        ])
    }

    func setUpGuideCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0

        guideCollectionView = UICollectionView(frame: self.contentView.bounds, collectionViewLayout: layout)
        guideCollectionView.backgroundColor = .clear
        guideCollectionView.delegate = self
        guideCollectionView.dataSource = self
        //guideCollectionView.isPagingEnabled = true
        guideCollectionView.showsHorizontalScrollIndicator = false

        guideCollectionView.register(guideCell.self, forCellWithReuseIdentifier: cellIdentifier)
        contentView.addSubview(guideCollectionView)

        guideCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            guideCollectionView.heightAnchor.constraint(equalToConstant: 252),
            guideCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            guideCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            guideCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }


    // MARK: - UICollectionViewDataSource


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return guideList.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = guideCollectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! guideCell
        let guide = guideList[indexPath.item]
        cell.imageView.loadImage(from: guide.imageUrl)
        cell.backgroundColor = .clear
        cell.heartImageView.isHidden = true
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let guide = guideList[indexPath.item]
        open(urlString: guide.link)
    }

    // MARK: - UICollectionViewDelegateFlowLayout

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }

    func configure(with guide: [Guide]){
        self.guideList = guide
    }
}
