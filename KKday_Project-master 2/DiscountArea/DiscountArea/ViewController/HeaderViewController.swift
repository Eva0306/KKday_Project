

import UIKit

class HeaderViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CountrySelectorViewDelegate, HTTPRequestManagerDelegate {
    
    var countries: [Category] = []
    var coupons: [Coupon] = []
    var noticeData: String? = nil
    var sectionTitles: [String] = []
    var sectionLabels: [UILabel] = []
    var sections: [Config] = []
    var selectedCountry: Category? {
        didSet {
            fetchSectionData(for: selectedCountry)
        }
    }
    
    let titleLabel = UILabel()
    let requestManager = HTTPRequestManager()
    var countrySelectorView: CountrySelectorView?
    var tableView: UITableView!
    var dropdownButton: UIButton!
    var sectionHeaderView: UIView!
    var popupView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        requestManager.delegate = self
        requestManager.fetchPageData()
    }
    
    func setupUI() {
        setupBackgroundImageView()
        setupTitleLabel()
        setupDropdownButton()
        setupSectionHeaderView()
        view.bringSubviewToFront(sectionHeaderView)
    }
    
    func setupBackgroundImageView() {
        let backgroundImageView = UIImageView()
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.clipsToBounds = true
        self.view.insertSubview(backgroundImageView, at: 0)
        
        if let backgroundImage = UIImage(named: "coupon_bg_color") {
            backgroundImageView.image = backgroundImage
        } else {
            backgroundImageView.backgroundColor = .systemTeal
        }
        
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -740)
        ])
    }
    
    func setupTitleLabel() {
        titleLabel.text = "優惠專區"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 22)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 80)
        ])
    }
    
    func setupDropdownButton() {
        var config = UIButton.Configuration.plain()
        config.title = "國家"
        config.baseForegroundColor = .black
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 16, weight: .light)
            return outgoing
        }
        
        if let originalImage = UIImage(systemName: "chevron.down") {
            config.image = resizeImage(originalImage, to: CGSize(width: 12, height: 6))
        }
        
        config.imagePadding = 8
        config.imagePlacement = .trailing
        config.baseBackgroundColor = .white
        config.background.strokeColor = .lightGray
        config.background.strokeWidth = 1.0
        config.background.cornerRadius = 15.0
        config.contentInsets = NSDirectionalEdgeInsets(top: 6.0, leading: 12.0, bottom: 6.0, trailing: 12.0)
        
        dropdownButton = UIButton(configuration: config, primaryAction: nil)
        dropdownButton.translatesAutoresizingMaskIntoConstraints = false
        dropdownButton.addTarget(self, action: #selector(showCountrySelector), for: .touchUpInside)
        view.addSubview(dropdownButton)
        
        NSLayoutConstraint.activate([
            dropdownButton.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 8),
            dropdownButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor)
        ])
    }
    
    func resizeImage(_ image: UIImage, to size: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
    }
    
    func setupSectionHeaderView() {
        sectionHeaderView = UIView()
        sectionHeaderView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(sectionHeaderView)
        
        NSLayoutConstraint.activate([
            sectionHeaderView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sectionHeaderView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            sectionHeaderView.topAnchor.constraint(equalTo: dropdownButton.bottomAnchor, constant: 10),
            sectionHeaderView.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        setupSectionLabels()
    }
    
    func setupSectionLabels() {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsHorizontalScrollIndicator = false
//        scrollView.backgroundColor = .red.withAlphaComponent(0.2) //Test
        scrollView.bounces = true
        sectionHeaderView.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: sectionHeaderView.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: sectionHeaderView.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: sectionHeaderView.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: sectionHeaderView.bottomAnchor)
        ])
        
        let underlineView = UIView()
        underlineView.backgroundColor = .systemTeal
        underlineView.translatesAutoresizingMaskIntoConstraints = false
        underlineView.backgroundColor = .systemTeal.withAlphaComponent(0.5) //Test
//        underlineView.frame = CGRect(x: 16, y: 38, width: 100, height: 2) // 手动设置一个初始位置和大小
        scrollView.addSubview(underlineView)
        
        var underlineLeadingConstraint: NSLayoutConstraint?
        var underlineWidthConstraint: NSLayoutConstraint?
        var previousLabel: UILabel?
        sectionLabels.removeAll()
        
        for (index, title) in sectionTitles.enumerated() {
            let label = UILabel()
            label.text = title
            label.font = UIFont.systemFont(ofSize: 16)
            label.textColor = index == 0 ? .systemTeal : .black
            label.isUserInteractionEnabled = true
            label.tag = index
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(sectionLabelTapped(_:)))
            label.addGestureRecognizer(tapGesture)
            
            label.translatesAutoresizingMaskIntoConstraints = false
            scrollView.addSubview(label)
            sectionLabels.append(label)
            
            NSLayoutConstraint.activate([
                label.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor),
                label.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
            ])
            
            if let previous = previousLabel {
                NSLayoutConstraint.activate([
                    label.leadingAnchor.constraint(equalTo: previous.trailingAnchor, constant: 16)
                ])
            } else {
                label.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16).isActive = true
                underlineLeadingConstraint = underlineView.leadingAnchor.constraint(equalTo: label.leadingAnchor)
                underlineWidthConstraint = underlineView.widthAnchor.constraint(equalTo: label.widthAnchor)
            }
            
            previousLabel = label
        }
        
        underlineLeadingConstraint?.isActive = true
        underlineWidthConstraint?.isActive = true
        underlineView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        underlineView.heightAnchor.constraint(equalToConstant: 2).isActive = true
        previousLabel?.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16).isActive = true
        print("Underline View Frame: \(underlineView.frame)")
    }
    
    func setupTableView() {
        tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableView.automaticDimension
        
        tableView.register(CouponTableViewCell.self, forCellReuseIdentifier: "CouponCell")
        tableView.register(NoticeTableViewCell.self, forCellReuseIdentifier: "NoticeCell")
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: sectionHeaderView.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    @objc func showCountrySelector() {
        if countrySelectorView == nil {
            countrySelectorView = CountrySelectorView(frame: CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: 500))
            countrySelectorView?.delegate = self
            countrySelectorView?.countries = countries
            countrySelectorView?.selectedCountry = selectedCountry
            view.addSubview(countrySelectorView!)
        }
        
        UIView.animate(withDuration: 0.3) {
            self.countrySelectorView?.frame.origin.y = self.view.frame.height - 500
            self.countrySelectorView?.layoutIfNeeded()
        }
    }
    
    
    func didSelectCountry(_ country: Category?) {
        selectedCountry = country
        hideCountrySelector()
        
        coupons.removeAll()
        sectionTitles.removeAll()
        
        sectionHeaderView.removeFromSuperview()
        setupSectionHeaderView()
        setupTableView()
        
        tableView.reloadData()
        
        if let selectedCountry = country {
            dropdownButton.setTitle(selectedCountry.name, for: .normal)
            //requestManager.fetchCoupons(for: selectedCountry.name)
            sectionTitles = selectedCountry.config.compactMap { $0.detail.title }
            updateSectionLabels()
        }
    }
    
    func hideCountrySelector() {
        UIView.animate(withDuration: 0.3, animations: {
            self.countrySelectorView?.frame.origin.y = self.view.frame.height
            self.countrySelectorView?.layoutIfNeeded()
        }) { _ in
            self.countrySelectorView?.removeFromSuperview()
            self.countrySelectorView = nil
        }
    }
    
    func fetchSectionData(for country: Category?) {
        guard let country = country else { return }
        sectionTitles = country.config.compactMap { $0.detail.title }
        tableView.reloadData()
        updateSectionLabels()
    }
    
    func updateSectionLabels() {
        for label in sectionLabels {
            label.removeFromSuperview()
        }
        sectionLabels.removeAll()
        setupSectionLabels()
    }
    
    @objc func sectionLabelTapped(_ sender: UITapGestureRecognizer) {
        if let label = sender.view as? UILabel, let index = sectionLabels.firstIndex(of: label) {
            guard index < tableView.numberOfSections else {
                print("Attempted to scroll to an out-of-bounds section: \(index)")
                return
            }
            
            let rowCount = tableView.numberOfRows(inSection: index)
                guard rowCount > 0 else {
                    print("No rows in section \(index). Cannot scroll.")
                    return
                }
            
            for (i, lbl) in sectionLabels.enumerated() {
                lbl.font = i == index ? UIFont.boldSystemFont(ofSize: 16) : UIFont.systemFont(ofSize: 16)
                lbl.textColor = i == index ? .systemTeal : .black
            }
            
            let indexPath = IndexPath(row: 0, section: index)
            tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        }
    }
    
    func populateSections(from configs: [Config]) {
        sections = configs.filter { config in
            if config.type == "COUPON", let coupons = config.detail.coupons, !coupons.isEmpty {
                return true
            } else if config.type == "DESCRIPTION", let _ = config.detail.title {
                return true
            }
            return false
        }
        tableView.reloadData()
    }
    
    // MARK: - HTTPRequestManagerDelegate (Specific Methods)
        
        func manager(_ manager: HTTPRequestManager, didGet pageData: ResponsePageData) {
            // 如果不需要特殊处理，可以将其留空或者直接调用通用方法
            self.manager(manager, didGet: pageData as Any)
        }
        
        func manager(_ manager: HTTPRequestManager, didGet productData: ResponseProductData) {
            self.manager(manager, didGet: productData as Any)
        }
        
        func manager(_ manager: HTTPRequestManager, didGet coupons: [Coupon]) {
            self.manager(manager, didGet: coupons as Any)
        }
        
        // MARK: - HTTPRequestManagerDelegate (General Methods)
        
        func manager(_ manager: HTTPRequestManager, didGet data: Any) {
            if let pageData = data as? ResponsePageData {
                handlePageData(pageData)
            } else if let coupons = data as? [Coupon] {
                handleCoupons(coupons)
            } else if let productData = data as? ResponseProductData {
                handleProductData(productData)
            } else {
                print("Received unknown data type")
            }
        }

        func manager(_ manager: HTTPRequestManager, didFailWith error: Error) {
            print("Failed to fetch data: \(error.localizedDescription)")
        }

        // MARK: - Private Methods

        private func handlePageData(_ pageData: ResponsePageData) {
            countries = pageData.data.data.categories
            countrySelectorView?.countries = countries
            // 更新UI或其他處理
        }

        private func handleCoupons(_ coupons: [Coupon]) {
            self.coupons = coupons
            tableView.isHidden = false
            tableView.reloadData()
        }
    
        private func handleProductData(_ productData: ResponseProductData) {
            // 這個方法可能在 HeaderViewController 中不會用到，你可以留空或者日後實現具體邏輯
        }
    // MARK: - UITableViewDataSource, UITableViewDelegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? coupons.count : 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.section < sectionTitles.count else {
            return UITableViewCell()
        }
        
        if indexPath.section == 0 {
            guard indexPath.row < coupons.count,
                  let cell = tableView.dequeueReusableCell(withIdentifier: "CouponCell", for: indexPath) as? CouponTableViewCell else {
                return UITableViewCell()
            }
            let coupon = coupons[indexPath.row]
            cell.configure(with: coupon)
            
            cell.redeemAction = { [weak self] in
                self?.showPopupView()
            }
            return cell
        } else {
            return tableView.dequeueReusableCell(withIdentifier: "NoticeCell", for: indexPath) as? NoticeTableViewCell ?? UITableViewCell()
        }
    }
    
    func showPopupView() {
        let popupView = UIView()
        popupView.backgroundColor = .white
        popupView.layer.cornerRadius = 20
        popupView.layer.masksToBounds = true
        popupView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(popupView)
        
        let handleView = UIView()
        handleView.backgroundColor = .lightGray
        handleView.layer.cornerRadius = 2.5
        handleView.translatesAutoresizingMaskIntoConstraints = false
        popupView.addSubview(handleView)
        
        let googleButton = UIButton(type: .system)
        googleButton.setTitle("Google 登入", for: .normal)
        googleButton.backgroundColor = .systemTeal
        googleButton.tintColor = .white
        googleButton.layer.cornerRadius = 10
        googleButton.translatesAutoresizingMaskIntoConstraints = false
        popupView.addSubview(googleButton)
        
        let closeButton1 = UIButton(type: .system)
        closeButton1.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton1.tintColor = .black
        closeButton1.addTarget(self, action: #selector(closePopupView), for: .touchUpInside)
        closeButton1.translatesAutoresizingMaskIntoConstraints = false
        popupView.addSubview(closeButton1)
        
        let closeButton2 = UIButton(type: .system)
        closeButton2.setTitle("關閉", for: .normal)
        closeButton2.tintColor = .systemTeal
        closeButton2.addTarget(self, action: #selector(closePopupView), for: .touchUpInside)
        closeButton2.translatesAutoresizingMaskIntoConstraints = false
        popupView.addSubview(closeButton2)
        
        let imageView = UIImageView(image: UIImage(named: "allCUTE"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        popupView.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            popupView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            popupView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            popupView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            popupView.heightAnchor.constraint(equalToConstant: 300),
            
            handleView.topAnchor.constraint(equalTo: popupView.topAnchor, constant: 8),
            handleView.centerXAnchor.constraint(equalTo: popupView.centerXAnchor),
            handleView.widthAnchor.constraint(equalToConstant: 44),
            handleView.heightAnchor.constraint(equalToConstant: 2.5),
            
            imageView.topAnchor.constraint(equalTo: popupView.topAnchor, constant: 40),
            imageView.centerXAnchor.constraint(equalTo: popupView.centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 100),
            imageView.heightAnchor.constraint(equalToConstant: 100),
            
            googleButton.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            googleButton.centerXAnchor.constraint(equalTo: popupView.centerXAnchor),
            googleButton.widthAnchor.constraint(equalToConstant: 200),
            googleButton.heightAnchor.constraint(equalToConstant: 50),
            
            closeButton1.leadingAnchor.constraint(equalTo: popupView.leadingAnchor, constant: 16),
            closeButton1.topAnchor.constraint(equalTo: popupView.topAnchor, constant: 20),
            
            closeButton2.topAnchor.constraint(equalTo: googleButton.bottomAnchor, constant: 10),
            closeButton2.centerXAnchor.constraint(equalTo: popupView.centerXAnchor),
            closeButton2.widthAnchor.constraint(equalToConstant: 100),
            closeButton2.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        popupView.transform = CGAffineTransform(translationX: 0, y: 300)
        UIView.animate(withDuration: 0.3) {
            popupView.transform = .identity
        }
        self.popupView = popupView
    }
    
    @objc func closePopupView() {
        UIView.animate(withDuration: 0.3, animations: {
            self.popupView?.transform = CGAffineTransform(translationX: 0, y: 300)
        }) { _ in
            self.popupView?.removeFromSuperview()
            
            self.popupView = nil
        }
    }
}

