import UIKit


class PromoCollectionViewController: UIViewController {
    
    // MARK: Properties
    // Country select
    let countrySelector: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("選擇國家", for: .normal)
        button.backgroundColor = .lightGray
        button.layer.cornerRadius = 5
        return button
    }()
    
    let optionsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.isHidden = true
        return stackView
    }()
    
    let countries = ["台灣", "日本", "韓國", "港澳", "泰國", "新加坡", "馬來西亞", "美國", "法國", "澳洲", "印尼", "菲律賓", "加拿大"]
    
    // Collection View
//    let factory = CollectionViewFactory()
//    lazy var collectionView = factory.createCollectionView(for: .tabGrid)
    
    let tabs = ["海邊漫遊", "賞櫻行程", "山林步道縱走", "精選包車"]
    var selectedTabIndex = 0
    var configList: [Config] = []
    lazy var collectionView = UICollectionView()
    var products: [testProduct] = [] // Your test product data model
    var httpRequestManager = HTTPRequestManager()
    
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        view.backgroundColor = .systemPink
        
        super.viewDidLoad()
        
        httpRequestManager.delegate = self
        
        setupCountrySelector()
        setupTestProductsData()
        httpRequestManager.fetchPageData()
    }
    
    // MARK: Function
    func setupCountrySelector() {
        view.addSubview(countrySelector)
        view.addSubview(optionsStackView)
        
        countrySelector.translatesAutoresizingMaskIntoConstraints = false
        optionsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            countrySelector.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            countrySelector.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            countrySelector.widthAnchor.constraint(equalToConstant: 120),
            countrySelector.heightAnchor.constraint(equalToConstant: 20),
            
            optionsStackView.topAnchor.constraint(equalTo: countrySelector.bottomAnchor),
            optionsStackView.leadingAnchor.constraint(equalTo: countrySelector.leadingAnchor),
            optionsStackView.widthAnchor.constraint(equalTo: countrySelector.widthAnchor)
        ])
        
        countrySelector.addTarget(self, action: #selector(selectorOpen), for: .touchUpInside)
        
        for country in countries {
            let button = UIButton(type: .system)
            button.setTitle(country, for: .normal)
            button.backgroundColor = .white
            button.addTarget(self, action: #selector(getSelect), for: .touchUpInside)
            optionsStackView.addArrangedSubview(button)
        }
    }
    
    @objc func selectorOpen(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3) {
            self.optionsStackView.isHidden.toggle()
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func getSelect(_ sender: UIButton) {
        guard let countryName = sender.currentTitle else { return }
        countrySelector.setTitle(countryName, for: .normal)
        selectorOpen(countrySelector) // 關閉下拉選單
//        fetchDataForCountry(countryName)
    }
    
    func fetchDataForCountry(_ country: String) {
        // 這裡實現API調用邏輯
        // 調用完成後更新tabs和products
        // 例如：
        // APIManager.fetchData(forCountry: country) { [weak self] result in
        //     switch result {
        //     case .success(let responseData):
        //         self?.updateUI(with: responseData)
        //     case .failure(let error):
        //         print("Error fetching data: \(error)")
        //     }
        // }
    }
    
//    func updateUI(with responseData: ResponsePageData) {
//        // 更新tabs
//        self.tabs = responseData.data.categories.flatMap { $0.config.flatMap { $0.detail.tabs?.map { $0.name } ?? [] } }
//        
//        // 更新products
//        self.products = responseData.data.categories.flatMap { category in
//            category.config.flatMap { config in
//                config.detail.tabs?.flatMap { $0.products } ?? []
//            }
//        }
//        
//        // 重新加載CollectionView
//        DispatchQueue.main.async {
//            self.collectionView.reloadData()
//        }
//    }
    
    
    func setupCollectionView() {
        let factory = CollectionViewFactory()
        guard let layoutType = configList[4].detail.layout else { return }
        
        let layout: PromoLayoutType
        switch layoutType {
        case "GRID":
            layout = .grid
        case "ROW":
            layout = .row
        case "TAB_GRID":
            layout = .tabGrid
        case "TAB_ROW":
            layout = .tabRow
        default:
            return
        }
        collectionView = factory.createCollectionView(for: layout)
        
        view.addSubview(collectionView)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(PromoTabCell.self, forCellWithReuseIdentifier: "TabCell")
        collectionView.register(PromoProductCell.self, forCellWithReuseIdentifier: "ProductCell")
    }
    
    func setupTestProductsData() {
        let product = testProduct(
            imgUrl: "placeHolder",
            discount: 50,
            name: "【花蓮豐濱景點】磯崎大石鼻山步道 整修重新開放！",
            ratingStar: 4.6,
            ratingCount: 20,
            originalPrice: "1000",
            price: "999"
        )
        
        // Create 8 identical products
        products = Array(repeating: product, count: 8)
    }
}

// MARK: - HTTPManagerRequest
extension PromoCollectionViewController: HTTPRequestManagerDelegate {
    func manager(_ manager: HTTPRequestManager, didGet pageData: ResponsePageData) {
        self.configList = pageData.data.data.categories[2].config
        print(configList)
        self.setupCollectionView()
    }
    
    func manager(_ manager: HTTPRequestManager, didGet productData: ResponseProductData) {
        
    }
    
    func manager(_ manager: HTTPRequestManager, didFailWith error: any Error) {
        print(error)
    }
    
    
}
    
// MARK: - UICollectionViewDataSource
extension PromoCollectionViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard let layoutType = configList[4].detail.layout else { return 0}
        
        let layout: PromoLayoutType
        switch layoutType {
        case "GRID":
            layout = .grid
        case "ROW":
            layout = .row
        case "TAB_GRID":
            layout = .tabGrid
        case "TAB_ROW":
            layout = .tabRow
        default:
            layout = .grid
        }
         
        if layout == .tabGrid || layout == .tabRow {
            return 2
        } else {
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let layoutType = configList[4].detail.layout else { return 0 }
        
        let layout: PromoLayoutType
        switch layoutType {
        case "GRID":
            layout = .grid
        case "ROW":
            layout = .row
        case "TAB_GRID":
            layout = .tabGrid
        case "TAB_ROW":
            layout = .tabRow
        default:
            layout = .grid
        }
        if layout == .tabGrid || layout == .tabRow {
            if section == 0 {
                return configList[4].detail.tabs?.count ?? 0
            } else {
                return configList[4].detail.tabs?[0].products.count ?? 0
            }
        } else {
            return min(configList[4].detail.products?.count ?? 0, 8)
        }
        //return section == 0 ? tabs.count : 8
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let layoutType = configList[4].detail.layout else { return UICollectionViewCell()}
        
        let layout: PromoLayoutType
        switch layoutType {
        case "GRID":
            layout = .grid
        case "ROW":
            layout = .row
        case "TAB_GRID":
            layout = .tabGrid
        case "TAB_ROW":
            layout = .tabRow
        default:
            layout = .grid
        }
        
        if layout == .tabGrid || layout == .tabRow {
            if indexPath.section == 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TabCell", for: indexPath) as! PromoTabCell
                cell.configure(with: tabs[indexPath.item], isSelected: indexPath.item == selectedTabIndex)
                return cell
                
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCell", for: indexPath) as! PromoProductCell
                cell.configure(with: products[indexPath.item])
                return cell
            }
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCell", for: indexPath) as! PromoProductCell
            cell.configure(with: products[indexPath.item])
            return cell
        }
    }
}


// MARK: - UICollectionViewDelegate
extension PromoCollectionViewController: UICollectionViewDelegate {
    
    // TODO: 可要可不要，看遮罩
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            cell.alpha = 0
            
            UIView.animate(withDuration: 0.5, delay: 0.05, options: .curveEaseInOut, animations: {
                cell.alpha = 1
            })
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            selectedTabIndex = indexPath.item
            
            // Here you would typically reload your product data based on the selected tab
            //            fetchProductsForSelectedTab { [weak self] newProducts in
            //                guard let self = self else { return }
            //                self.products = newProducts // 更新產品數據源
            //
            //                // 重新加載產品 section 以顯示新數據
            //                self.collectionView.reloadSections(IndexSet(integer: 1))
            //            }
            collectionView.reloadSections(IndexSet(integer: 1))
            collectionView.reloadSections(IndexSet(integer: 0))
            
        } else {
            // 跳出打開safari導到網頁
        }
    }
}

