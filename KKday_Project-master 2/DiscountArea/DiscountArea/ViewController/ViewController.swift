

import UIKit

class ViewController: UIViewController, CountrySelectorViewDelegate {
    
    var httpRequestManager = HTTPRequestManager()
    
    var tableView = UITableView()
    
    let titleLabel = UILabel()
    
    var countrySelectorView: CountrySelectorView?
    
    var dropdownButton: UIButton!
    
    var sectionHeaderView: UIView!
    
    var popupView: UIView?
    
    var countries: [Category] = []
    
    var sectionTitles: [String] = []
    
    var sectionLabels: [UILabel] = []
    
    var selectedCountry: Category? {
        didSet {
            fetchSectionData(for: selectedCountry)
        }
    }
    
    var configList: [Config] = [] {
        didSet {
            print(">>>>>>>>>\n", configList)
//            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        httpRequestManager.delegate = self
        
        setupUI()
        setupTableView()

        httpRequestManager.fetchPageData()
        
        tableView.register(MerchantCouponContainerCell.self, forCellReuseIdentifier: "MerchantCouponContainerCell")
        tableView.register(PromoContainerCell.self, forCellReuseIdentifier: "PromoContainerCell")
        tableView.register(GuideContainerCell.self, forCellReuseIdentifier: "GuideContainerCell")
        tableView.register(CouponContainerCell.self, forCellReuseIdentifier: "CouponContainerCell")
    }
    
    func setupUI() {
        setupBackgroundImageView()
        setupTitleLabel()
        setupDropdownButton()
        setupSectionHeaderView()
        view.bringSubviewToFront(sectionHeaderView)
    }
    
    func setupTableView() {
        tableView.showsVerticalScrollIndicator = false
        
        view.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: sectionHeaderView.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
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
        self.configList = []
        
        selectedCountry = country
        hideCountrySelector()
        
        sectionTitles.removeAll()
        
        // DOING
//        sectionHeaderView.removeFromSuperview()
//        setupSectionHeaderView()
        
        
        if let selectedCountry = country {
            self.configList = selectedCountry.config
            dropdownButton.setTitle(selectedCountry.name, for: .normal)
            sectionTitles = selectedCountry.config.compactMap { $0.detail.title }
            updateSectionLabels()
            
            tableView.reloadData()
            
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
}

extension ViewController: HTTPRequestManagerDelegate {
    func manager(_ manager: HTTPRequestManager, didGet pageData: ResponsePageData) {
        
        countries = pageData.data.data.categories
        countrySelectorView?.countries = countries
        
        self.configList = pageData.data.data.categories[0].config
        
        tableView.reloadData()
    }
    
    func manager(_ manager: HTTPRequestManager, didGet productData: ResponseProductData) {
        
    }
    
    func manager(_ manager: HTTPRequestManager, didFailWith error: any Error) {
        print(error)
    }
    
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 500
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return configList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let config = configList[indexPath.row]
        
        if config.type == "MERCHANT_COUPON" {

            let cell = tableView.dequeueReusableCell(withIdentifier: "MerchantCouponContainerCell", for: indexPath) as! MerchantCouponContainerCell

            if let merchantCoupons = config.detail.merchantCoupons {
                cell.configure(with: merchantCoupons)
                //cell.configure(with: merchantCoupons, isExpanded: merchantCouponisExpanded)
            } else {
                print("沒有商家優惠券")
            }

            cell.delegate = self

            return cell
            
        } else if config.type == "PRODUCT" && config.detail.layout == "HIGHLIGHT"{
            let cell = tableView.dequeueReusableCell(withIdentifier: "PromoContainerCell", for: indexPath) as! PromoContainerCell
            
            
            return cell

        } else if config.type == "PRODUCT" && config.detail.layout != nil {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "PromoContainerCell", for: indexPath) as! PromoContainerCell
            
            cell.configure(with: config.detail)
            
            return cell
            
        } else if config.type == "GUIDE" {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "GuideContainerCell", for: indexPath) as! GuideContainerCell
            
            if let guides = config.detail.guides {
                cell.configure(with: guides)
            }
            
            return cell
            
        } else if config.type == "COUPON" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CouponContainerCell", for: indexPath) as! CouponContainerCell
            if let coupons = config.detail.coupons {
                cell.configure(with: coupons)
            }
            return cell
        }

        return UITableViewCell()
    }
}

//MARK: - Merchant Coupon Container Cell Delegate
extension ViewController: MerchantCouponContainerCellDelegate {
    
    func didSelectMerchantCoupon(_ coupon: MerchantCoupon) {
        let imageVC = MerchantCouponImageViewController()
        imageVC.merchantCoupon = coupon
        
        let navController = UINavigationController(rootViewController: imageVC)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true, completion: nil)
    }
}
