

import UIKit

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, HTTPRequestManagerDelegate {

    var httpRequestManager = HTTPRequestManager()
    var products: [Product] = []
    var configList: [Config] = []
    var productData: [DiscountArea.ProductData] = []
    var productList: [String] = []
    var semaphore = DispatchSemaphore(value: 0)

    var mainProductLabel = UILabel()
    var bestOfferLabel = UILabel()
    var collectionView: UICollectionView!
    var guideCollectionView: UICollectionView!
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
            self.httpRequestManager.fetchPageData()
            self.semaphore.wait()
            DispatchQueue.main.async {
                self.httpRequestManager.fetchProductData(productList: self.productList)
//                self.setUpGuideCollectionView()
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

        NSLayoutConstraint.activate([
            mainProductLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            mainProductLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mainProductLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            bestOfferLabel.topAnchor.constraint(equalTo: mainProductLabel.bottomAnchor, constant: 10),
            bestOfferLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bestOfferLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    func setUpGuideCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0

        guideCollectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: layout)
        guideCollectionView.backgroundColor = .white
        guideCollectionView.delegate = self
        guideCollectionView.dataSource = self
        guideCollectionView.isPagingEnabled = true
        guideCollectionView.showsHorizontalScrollIndicator = false

        guideCollectionView.register(promoProductCell.self, forCellWithReuseIdentifier: cellIdentifier)
        view.addSubview(guideCollectionView)

        guideCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            guideCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),
            guideCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            guideCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            guideCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
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

        if collectionView == self.collectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! promoProductCell
            if productData.isEmpty {
                cell.imageView.image = UIImage(named: "placeHolder")
            } else {
                let product = productData[indexPath.item]
                cell.imageView.loadImage(from: product.imgUrl)
                cell.configure(labelTexts: [product.name, " 星等 \(product.ratingStar) (\(product.ratingCount))| 6K+ 已訂購"])
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
        } else if collectionView == guideCollectionView{
            let cell = guideCollectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! promoProductCell

            cell.imageView.loadImage(from: "https://image.kkday.com/v2/image/get/s1.kkday.com/campaign_3667/20240716061550_M1GJa/jpg")
            cell.gradientView.isHidden = true
            cell.gradientLayer.isHidden = true
            return cell
        }
        return UICollectionViewCell()
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        if collectionView == self.collectionView{
            let product = productData[indexPath.item]
            if let url = URL(string: "https://www.kkday.com/zh-tw/product/\(product.id)") {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:])
                }
            }
        } else if collectionView == guideCollectionView {
            if let url = URL(string: "https://www.kkday.com/zh-tw/blog/3880/asia-taiwan-taichung-10-spot") {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:])
                }
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

    func manager(_ manager: HTTPRequestManager, didGet pageData: ResponsePageData) {
        self.configList = pageData.data.data.categories[2].config
//        print("BBBB\(self.configList)")
        if let highlightConfig = self.configList.first(where: { $0.detail.layout == "HIGHLIGHT" }) {
            if let products = highlightConfig.detail.products {
                productList = products.compactMap { $0.productUrlId }
                print("Highlight Product IDs: \(productList)")
            } else {
                print("No products found in HIGHLIGHT section.")
            }
        } else {
            print("No HIGHLIGHT layout found.")
        }
        semaphore.signal()
    }

    func didReceiveProductData(_ manager: HTTPRequestManager, products: [DiscountArea.ProductData]) {
        self.productData = products
        collectionView.reloadData()
    }

    func manager(_ manager: HTTPRequestManager, didFailWith error: any Error) {
        return
    }
}
