

import UIKit

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, HTTPRequestManagerDelegate {

    var httpRequestManager = HTTPRequestManager()
    var products: [Product] = []
    var productData: [DiscountArea.ProductData] = []
    var productList: [String] = []
    var semaphore = DispatchSemaphore(value: 0)

    var mainProductLabel = UILabel()
    var bestOfferLabel = UILabel()
    var collectionView: UICollectionView!
    var timer: Timer?
    var selectedTag: Int = 0
    let cellIdentifier = "CustomCell"
    let images: [UIColor] = [.systemPink, .systemOrange, .yellow, .systemGreen, .darkGray]

    override func viewDidLoad() {
        print("====DidLoad====")
        super.viewDidLoad()
        httpRequestManager.delegate = self
        setupTitles()
        DispatchQueue.global().async {
            self.httpRequestManager.fetchPageData(tag: 0, sort: 2)
            self.semaphore.wait()
            DispatchQueue.main.async {
                self.httpRequestManager.fetchProductData(productList: self.productList)
                self.setupCollectionView()
                self.startAutoScrollTimer()
            }
        }
    }

    func setupTitles() {
        mainProductLabel.text = "主打商品"
        mainProductLabel.font = UIFont.boldSystemFont(ofSize: 24)
        mainProductLabel.textAlignment = .center
        mainProductLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mainProductLabel)

        bestOfferLabel.text = "最優惠的商品看這邊"
        bestOfferLabel.font = UIFont.systemFont(ofSize: 18)
        bestOfferLabel.textColor = .gray
        bestOfferLabel.textAlignment = .center
        bestOfferLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bestOfferLabel)

        // Add constraints for the labels
        NSLayoutConstraint.activate([
            mainProductLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            mainProductLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mainProductLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            bestOfferLabel.topAnchor.constraint(equalTo: mainProductLabel.bottomAnchor, constant: 10),
            bestOfferLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bestOfferLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
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

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
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

        if productData.isEmpty {
            cell.imageView.image = UIImage(named: "placeHolder")
        } else {
            let product = productData[indexPath.item]
            cell.imageView.loadImage(from: product.imgUrl)
            cell.configure(labelTexts: [product.name, " 星等 \(product.ratingStar) (\(product.ratingCount))"])
            cell.price.text = "\(product.currency) \(product.price)"
            cell.price.font = UIFont.boldSystemFont(ofSize: 18)

            if product.price != product.originPrice{
                cell.originPrice.textColor = .gray
                cell.originPrice.attributedText = NSAttributedString(
                    string: "\(product.currency) \(product.originPrice)",
                    attributes: [
                        .strikethroughStyle: NSUnderlineStyle.single.rawValue
                    ]
                )
            }
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let product = productData[indexPath.item]
        if let url = URL(string: "https://www.kkday.com/zh-tw/product/\(product.id)") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:])
            }
        }
    }

    // MARK: - UICollectionViewDelegateFlowLayout

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
    }

    // MARK: - HTTPRequestManagerDelegate

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
        self.productData = products
        collectionView.reloadData()
    }

    func manager(_ manager: HTTPRequestManager, didFailWith error: any Error) {
        return
    }
}
