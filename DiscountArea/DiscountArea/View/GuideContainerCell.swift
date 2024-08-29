//
//  GuideContainerCell.swift
//  DiscountArea
//
//  Created by J oyce on 2024/8/27.
//

import Foundation
import UIKit

class GuideContainerCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var guideList: [Guide] = [] {
        didSet{
            guideCollectionView.reloadData()
            pageControl.numberOfPages = guideList.count
            guideCollectionView.layoutIfNeeded()
        }
    }

    var backgroundImageView = UIImageView()

    var guideCollectionView: UICollectionView!
    var pageControl: UIPageControl!

    let cellIdentifier = "guideCell"

    var timer: Timer?

    var currentIndex = 0

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupBackground()
        setUpGuideCollectionView()
        setupPageControl()
        startAutoScrollTimer()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guideCollectionView.frame = contentView.bounds
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
            backgroundImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
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

    func setupPageControl() {
        pageControl = UIPageControl()
        pageControl.currentPageIndicatorTintColor = .gray
        pageControl.pageIndicatorTintColor = UIColor.lightGray
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(pageControl)

        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            pageControl.heightAnchor.constraint(equalToConstant: 20),
            pageControl.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5)
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

    func startAutoScrollTimer() {
        timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(autoScroll), userInfo: nil, repeats: true)
        print("Auto-scroll timer started.")
    }

    @objc func autoScroll() {
        guard let collectionView = guideCollectionView else { return }

        collectionView.layoutIfNeeded()

        let totalItems = guideList.count
        let itemWidth = 320.0
        let currentOffset = collectionView.contentOffset.x
        let currentIndex = Int(round(currentOffset / itemWidth))

        let nextItem = (currentIndex + 1) % totalItems

        let nextIndexPath = IndexPath(item: nextItem, section: 0)
        pageControl.currentPage = nextItem

        let targetOffset = CGPoint(x: CGFloat(nextItem) * itemWidth , y: 0)
        if nextIndexPath.item == 0{
            collectionView.setContentOffset(targetOffset, animated: false)
        } else {
            collectionView.setContentOffset(targetOffset, animated: true)
        }
    }

    func stopAutoScrollTimer() {
        timer?.invalidate()
        timer = nil
    }
}
