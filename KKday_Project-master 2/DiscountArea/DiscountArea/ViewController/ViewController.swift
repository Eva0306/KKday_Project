

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
    var underlineView: UIView?
    var underlineLeadingConstraint: NSLayoutConstraint?
    var underlineWidthConstraint: NSLayoutConstraint?
    
    var selectedCountry: Category? {
        didSet {
            fetchSectionData(for: selectedCountry)
        }
    }
    
    var configList: [Config] = [] {
        didSet {
            print(">>>>>>>>>\n", configList)
            tableView.reloadData()
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
        
        tableView.register(TitleCell.self, forCellReuseIdentifier: "TitleCell")
        tableView.register(MerchantCouponContainerCell.self, forCellReuseIdentifier: "MerchantCouponContainerCell")
        tableView.register(PromoContainerCell.self, forCellReuseIdentifier: "PromoContainerCell")
        tableView.register(GuideContainerCell.self, forCellReuseIdentifier: "GuideContainerCell")
        tableView.register(HighlightContainerCell.self, forCellReuseIdentifier: "HighlightContainerCell")
        tableView.register(CouponContainerCell.self, forCellReuseIdentifier: "CouponContainerCell")
        tableView.register(NoticeTableViewCell.self, forCellReuseIdentifier: "NoticeTableViewCell")
        
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
        
        tableView.separatorStyle = .none
        
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

        sectionLabels.forEach { $0.removeFromSuperview() }
        sectionLabels.removeAll()
        underlineView?.removeFromSuperview()
        
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bounces = true
        sectionHeaderView.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: sectionHeaderView.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: sectionHeaderView.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: sectionHeaderView.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: sectionHeaderView.bottomAnchor)
        ])
        
        let underlineView = UIView()
        underlineView.translatesAutoresizingMaskIntoConstraints = false
        underlineView.backgroundColor = .systemTeal.withAlphaComponent(0.5)
        scrollView.addSubview(underlineView)
        self.underlineView = underlineView
        
        var previousLabel: UILabel?
        
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
                NSLayoutConstraint.activate([
                    label.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16)
                ])
                
                underlineLeadingConstraint = underlineView.leadingAnchor.constraint(equalTo: label.leadingAnchor)
                underlineWidthConstraint = underlineView.widthAnchor.constraint(equalTo: label.widthAnchor)
                underlineLeadingConstraint?.isActive = true
                underlineWidthConstraint?.isActive = true
            }
            
            previousLabel = label
        }
        
        previousLabel?.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16).isActive = true
        underlineView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        underlineView.heightAnchor.constraint(equalToConstant: 2).isActive = true
        
        print("ScrollView Content Size: \(scrollView.contentSize)")
        print("Underline View Frame: \(underlineView.frame)")
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
            
            if let underlineView = underlineView {
                UIView.animate(withDuration: 0.3) {
                    underlineView.frame.origin.x = label.frame.origin.x
                    underlineView.frame.size.width = label.intrinsicContentSize.width
                }
            } else {
                print("underlineView is nil")
            }
            
            let indexPath = IndexPath(row: 0, section: index)
            tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        }
    }

    func populateSections(from configs: [Config]) {
        // Directly assign the configs to configList
        configList = configs.filter { config in
            switch config.type {
            case "MERCHANT_COUPON":
                return config.detail.merchantCoupons != nil
            case "PRODUCT":
                return config.detail.layout != nil
            case "GUIDE":
                return config.detail.guides != nil
            case "COUPON":
                return config.detail.coupons != nil
            case "DESCRIPTION":
                return config.detail.title != nil
            default:
                return false
            }
        }

        // Update sectionTitles based on the filtered configList
        sectionTitles = configList.compactMap { $0.detail.title }
        
        updateSectionLabels()
        tableView.reloadData()
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
        
        if let selectedCountry = country {
            self.configList = selectedCountry.config
            dropdownButton.setTitle(selectedCountry.name, for: .normal)
            populateSections(from: selectedCountry.config)
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
        populateSections(from: country.config)
        
    }
    
    func updateSectionLabels() {
        for label in sectionLabels {
            label.removeFromSuperview()
        }
        sectionLabels.removeAll()
        setupSectionLabels()
    }
}
    
extension ViewController: HTTPRequestManagerDelegate {
    func manager(_ manager: HTTPRequestManager, didGet pageData: ResponsePageData) {
        
        countries = pageData.data.data.categories
        countrySelectorView?.countries = countries
        
        self.configList = pageData.data.data.categories[0].config
        
        populateSections(from: pageData.data.data.categories[0].config)

    }
    
    func manager(_ manager: HTTPRequestManager, didGet productData: ResponseProductData) {
        
    }
    
    func manager(_ manager: HTTPRequestManager, didFailWith error: any Error) {
        print(error)
    }

}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return configList.count
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 500
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2 // Assuming each section has two rows: one for the title and one for the content
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let configIndex = indexPath.section
        let config = configList[configIndex]
        
        if indexPath.row == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "TitleCell", for: indexPath) as! TitleCell
            cell.configure(with: config.detail)
            
            cell.selectionStyle = .none
            return cell
            
        } else {
            if config.type == "MERCHANT_COUPON" {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "MerchantCouponContainerCell", for: indexPath) as! MerchantCouponContainerCell
                
                if let merchantCoupons = config.detail.merchantCoupons {
                    cell.configure(with: merchantCoupons)
                    cell.merchantCouponisExpanded = false
                } else {
                    print("沒有商家優惠券")
                }
                
                cell.delegate = self
                
                cell.selectionStyle = .none
                
                return cell
                
            } else if config.type == "PRODUCT" && config.detail.layout == "HIGHLIGHT" {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "HighlightContainerCell", for: indexPath) as! HighlightContainerCell
                
                if let highlights = config.detail.products {
                    cell.configure(with: highlights)
                }
                
                return cell
                
            } else if config.type == "PRODUCT" && config.detail.layout != nil {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "PromoContainerCell", for: indexPath) as! PromoContainerCell
                
                cell.configure(with: config.detail)
                
                cell.delegate = self
                
                cell.selectionStyle = .none
                
                return cell
                
            } else if config.type == "GUIDE" {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "GuideContainerCell", for: indexPath) as! GuideContainerCell
                
                if let guides = config.detail.guides {
                    cell.configure(with: guides)
                }
                
                cell.selectionStyle = .none
                
                return cell
                
            } else if config.type == "COUPON" {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "CouponContainerCell", for: indexPath) as! CouponContainerCell
                
                if let coupons = config.detail.coupons {
                    cell.configure(with: coupons)
                }
                
                return cell
                
            } else if config.type == "DESCRIPTION" {
                let cell = tableView.dequeueReusableCell(withIdentifier: "NoticeTableViewCell", for: indexPath) as! NoticeTableViewCell
                cell.configure(with: config.detail)
                return cell
            }
            
            return UITableViewCell()
        }
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

// MARK: - ScrollViewDelegate
extension ViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateSectionLabelBasedOnScrollPosition()
    }
    
    func updateSectionLabelBasedOnScrollPosition() {
        guard let visibleIndexPaths = tableView.indexPathsForVisibleRows, !visibleIndexPaths.isEmpty else {
            return
        }

        let firstVisibleSection = visibleIndexPaths[0].section
        updateSectionLabelStyles(selectedIndex: firstVisibleSection)
    }
    
    func updateSectionLabelStyles(selectedIndex: Int) {
        for (index, label) in sectionLabels.enumerated() {
            if index == selectedIndex {
                label.font = UIFont.boldSystemFont(ofSize: 16)
                label.textColor = .systemTeal
            } else {
                label.font = UIFont.systemFont(ofSize: 16)
                label.textColor = .black
            }
        }
        
        if let underlineView = underlineView {
            let selectedLabel = sectionLabels[selectedIndex]
            UIView.animate(withDuration: 0.3) {
                self.underlineView?.frame.origin.x = selectedLabel.frame.origin.x
                self.underlineView?.frame.size.width = selectedLabel.intrinsicContentSize.width
            }
        }
    }
}

extension ViewController: PromoContainerCellDelegate {
    func shouldDeleteTableViewCell(_ cell: PromoContainerCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            let previousIndexPath = IndexPath(row: indexPath.row - 1, section: indexPath.section)
            configList.remove(at: indexPath.row / 2)
            tableView.deleteRows(at: [indexPath, previousIndexPath], with: .automatic)

        }
    }
}
