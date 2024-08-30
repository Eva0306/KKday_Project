

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
    var scrollView: UIScrollView!
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
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
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
        
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bounces = true
        sectionHeaderView.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: sectionHeaderView.leadingAnchor, constant: 16),
            scrollView.trailingAnchor.constraint(equalTo: sectionHeaderView.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: sectionHeaderView.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: sectionHeaderView.bottomAnchor),
            scrollView.contentLayoutGuide.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        let underlineView = UIView()
        underlineView.translatesAutoresizingMaskIntoConstraints = false
        underlineView.backgroundColor = .systemTeal
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
                    label.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor)
                ])
                
                underlineLeadingConstraint = underlineView.leadingAnchor.constraint(equalTo: label.leadingAnchor)
                underlineWidthConstraint = underlineView.widthAnchor.constraint(equalToConstant: label.intrinsicContentSize.width)
            }
            
            previousLabel = label
        }
        
        if let underlineLeadingConstraint = underlineLeadingConstraint,
           let underlineWidthConstraint = underlineWidthConstraint {
            NSLayoutConstraint.activate([
                underlineLeadingConstraint,
                underlineWidthConstraint,
                underlineView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
                underlineView.heightAnchor.constraint(equalToConstant: 2)
            ])
        }
        
        previousLabel?.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16).isActive = true
        
        view.layoutIfNeeded()
    }
    
    @objc func sectionLabelTapped(_ sender: UITapGestureRecognizer) {
        if let label = sender.view as? UILabel, let index = sectionLabels.firstIndex(of: label) {

            guard index < configList.count else {

                print("Attempted to scroll to an out-of-bounds section: \(index)")
                return
            }
            
            updateSectionLabelStyles(selectedIndex: index)
            
            let indexPath = IndexPath(row: 0, section: index)
            tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        }
    }

    func populateSections(from configs: [Config]) {
        
        var mergedConfigs: [String: Config] = [:]
        var configOrder: [String] = []
        
        for config in configs {
            guard let title = config.detail.title else { continue }
            
            if var existingConfig = mergedConfigs[title] {
                if let newProducts = config.detail.products {
                    var mutableDetail = existingConfig.detail
                    var updatedProducts = mutableDetail.products ?? []
                    
                    updatedProducts.append(contentsOf: newProducts)
                    mutableDetail.products = updatedProducts
                    
                    existingConfig = Config(sort: existingConfig.sort, type: existingConfig.type, detail: mutableDetail)
                    
                    mergedConfigs[title] = existingConfig
                }
            } else {
                configOrder.append(title)
                mergedConfigs[title] = config
            }
        }
        
        configList = configOrder.compactMap { mergedConfigs[$0] }
        sectionTitles = configList.compactMap { $0.detail.title }
        updateSectionLabels()
        
        tableView.reloadData()
    }
    
    @objc func showCountrySelector() {
        addDarkOverlay()
 
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
            self.removeDarkOverlay()
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

    func addDarkOverlay() {
        let overlayView = UIView(frame: self.view.bounds)
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        overlayView.tag = 100
        overlayView.isUserInteractionEnabled = true
        self.view.addSubview(overlayView)
    }
    
    func removeDarkOverlay() {
        if let overlayView = self.view.viewWithTag(100) {
            overlayView.removeFromSuperview()
        }
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
        return 800
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
                
                cell.delegate = self
            
            return cell
            
        } else if config.type == "DESCRIPTION" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NoticeTableViewCell", for: indexPath) as! NoticeTableViewCell
            
            cell.configure(with: config.detail)
            return cell
        }
        
            return UITableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

        if let guideContainerCell = cell as? GuideContainerCell {
            guideContainerCell.startAutoScrollTimer()
        }
    }

    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {

        if let guideContainerCell = cell as? GuideContainerCell {
            guideContainerCell.stopAutoScrollTimer()
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

        guard let visibleIndexPaths = tableView.indexPathsForVisibleRows else { return }
        
        var firstFullyVisibleSection = visibleIndexPaths.first?.section ?? 0
        for indexPath in visibleIndexPaths {
            let rectInTableView = tableView.rectForRow(at: indexPath)
            let rectInSuperview = tableView.convert(rectInTableView, to: tableView.superview)
            if rectInSuperview.origin.y >= tableView.frame.origin.y + tableView.contentInset.top {
                firstFullyVisibleSection = indexPath.section
                break
            }
        }
        
        updateSectionLabelStyles(selectedIndex: firstFullyVisibleSection)
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
                UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut], animations: {
                    label.font = index == selectedIndex ? UIFont.boldSystemFont(ofSize: 16) : UIFont.systemFont(ofSize: 16)
                    label.textColor = index == selectedIndex ? .systemTeal : .black
                }, completion: nil)
            }

            let selectedLabel = sectionLabels[selectedIndex]
            let labelFrameInScrollView = selectedLabel.convert(selectedLabel.bounds, to: scrollView)

            let scrollViewWidth = scrollView.frame.width
            let offsetX = labelFrameInScrollView.midX - scrollViewWidth / 2
            let minOffsetX = 0.0
            let maxOffsetX = scrollView.contentSize.width - scrollViewWidth
            let targetOffsetX = max(minOffsetX, min(maxOffsetX, offsetX))

            UIView.animate(withDuration: 0.1, delay: 0, options: [.curveEaseInOut], animations: {
                self.scrollView.setContentOffset(CGPoint(x: targetOffsetX, y: 0), animated: false)
            }, completion: nil)

            UIView.animate(withDuration: 0.1, delay: 0, options: [.curveEaseInOut], animations: {
                self.underlineLeadingConstraint?.constant = selectedLabel.frame.origin.x
                self.underlineWidthConstraint?.constant = selectedLabel.intrinsicContentSize.width
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
}

extension ViewController: PromoContainerCellDelegate {
    func shouldDeleteTableViewCell(_ cell: PromoContainerCell) {

        guard let indexPath = tableView.indexPath(for: cell) else { return }
        
        configList.remove(at: indexPath.section)
        
        tableView.beginUpdates()
        tableView.reloadSections(IndexSet(integer: indexPath.section), with: .automatic)
        tableView.endUpdates()
    }
}

extension ViewController: CouponContainerCellDelegate {
    func didSelectCoupon() {
        showPopupView()
    }
}

extension ViewController {
    func showPopupView() {
        
        addDarkOverlay()
        
        let popupView = UIView()
        popupView.backgroundColor = .white
        popupView.layer.cornerRadius = 20
        popupView.layer.masksToBounds = true
        popupView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(popupView)
        
        let handleView = UIView()
        handleView.backgroundColor = .lightGray
        handleView.layer.cornerRadius = 2.5
        handleView.translatesAutoresizingMaskIntoConstraints = false
        popupView.addSubview(handleView)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        handleView.addGestureRecognizer(panGesture)
        
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

    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        guard let popupView = self.popupView else { return }
        
        let translation = gesture.translation(in: popupView)
        
        switch gesture.state {
        case .changed:
            if translation.y > 0 {
                popupView.transform = CGAffineTransform(translationX: 0, y: translation.y)
            }
        case .ended:
            if translation.y > 100 {
                closePopupView()
            } else {
                UIView.animate(withDuration: 0.3) {
                    popupView.transform = .identity
                }
            }
        default:
            break
        }
    }
    @objc func closePopupView() {
            UIView.animate(withDuration: 0.3, animations: {
                self.popupView?.transform = CGAffineTransform(translationX: 0, y: 300)
            }) { _ in
                self.popupView?.removeFromSuperview()
                self.popupView = nil
                self.removeDarkOverlay()
            }
        }
}
