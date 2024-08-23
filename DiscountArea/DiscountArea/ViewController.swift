

import UIKit

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, HTTPRequestManagerDelegate {

    var httpRequestManager = HTTPRequestManager()
    var products: [Product] = []
    var Pproducts: [DiscountArea.ProductData] = []
    var productList: [String] = []
    var semaphore = DispatchSemaphore(value: 0)

    var collectionView: UICollectionView!
    var timer: Timer?
    let cellIdentifier = "CustomCell"
    let images: [UIColor] = [.systemPink, .systemOrange, .yellow, .systemGreen, .darkGray]

    override func viewDidLoad() {
        super.viewDidLoad()

        httpRequestManager.delegate = self

        DispatchQueue.global().async {
            self.httpRequestManager.fetchPageData(tag: 10, sort: 2)
            self.semaphore.wait()
            DispatchQueue.main.async {
                self.httpRequestManager.fetchProductData(productList: self.productList)
                self.setupCollectionView()
                self.startAutoScrollTimer()
            }
        }
    }

    func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0

        collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false

        collectionView.register(promoProductCell.self, forCellWithReuseIdentifier: cellIdentifier)
        view.addSubview(collectionView)
    }

    func startAutoScrollTimer() {
        timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(autoScroll), userInfo: nil, repeats: true)
    }

    @objc func autoScroll() {
        guard let collectionView = collectionView else { return }

        let visibleItems = collectionView.indexPathsForVisibleItems
        if let currentIndexPath = visibleItems.first {
            let nextItem = (currentIndexPath.item + 1) % productList.count
            let nextIndexPath = IndexPath(item: nextItem, section: 0)

            if currentIndexPath.item == productList.count-1{
                let firstIndexPath = IndexPath(item: 0, section: 0)
                collectionView.scrollToItem(at: firstIndexPath, at: .centeredHorizontally, animated: false)
            } else {
                collectionView.scrollToItem(at: nextIndexPath, at: .centeredHorizontally, animated: true)
            }
        }
    }

    // MARK: - UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return productList.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! promoProductCell

        if Pproducts.isEmpty {
            // 显示占位内容
            cell.imageView.image = UIImage(named: "placeholder") // 默认图像
            cell.configure(labelTexts: ["加载中...", "加载中...", "加载中..."])
            cell.price.attributedText = NSAttributedString(
                string: "加载中...",
                attributes: [
                    .strikethroughStyle: NSUnderlineStyle.single.rawValue
                ]
            )
        } else {
            let product = Pproducts[indexPath.item]
            cell.imageView.loadImage(from: product.imgUrl)
            cell.configure(labelTexts: [
                product.name,
                "星等 \(product.ratingStar)",
                "\(product.currency) \(product.price)"
            ])
            cell.price.attributedText = NSAttributedString(
                string: "\(product.originPrice)",
                attributes: [
                    .strikethroughStyle: NSUnderlineStyle.single.rawValue
                ]
            )
        }

//        cell.imageView.loadImage(from: "\(Pproducts[1].imgUrl)")
//
//        cell.configure(labelTexts: ["\(Pproducts[1].name)", "星等 \(Pproducts[1].ratingStar)", "價錢\(Pproducts[1].currency)\(Pproducts[1].price)"])
//
//        cell.price.attributedText = NSAttributedString(
//            string: "價錢",
//            attributes: [
//                .strikethroughStyle: NSUnderlineStyle.single.rawValue
//            ]
//        )
//
//        cell.imageView.loadImage(from: "https://image.kkday.com/v2/image/get/w_600%2Cc_fit/s1.kkday.com/product_107922/20230221070205_NDApO/jpg")
//
//        cell.configure(labelTexts: ["品項名稱", "星等", "價錢"])
//
//        cell.price.attributedText = NSAttributedString(
//            string: "價錢",
//            attributes: [
//                .strikethroughStyle: NSUnderlineStyle.single.rawValue
//            ]
//        )
        return cell
    }

    // MARK: - UICollectionViewDelegateFlowLayout

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
    }

    func manager(_ manager: HTTPRequestManager, didGet data: Any) {
        return
    }

    func manager(_ manager: HTTPRequestManager, didGetProductList productList: [String]) {
        self.productList = productList
        print("Products of this category are \(self.productList)")
        semaphore.signal()
        return
    }

    func didReceiveProductData(_ manager: HTTPRequestManager, products: [DiscountArea.ProductData]) {
        self.Pproducts = products
        collectionView.reloadData()
    }

    func manager(_ manager: HTTPRequestManager, didFailWith error: any Error) {
        return
    }
}
