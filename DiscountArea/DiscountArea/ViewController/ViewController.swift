

import UIKit

class ViewController: UIViewController {
    
    var httpRequestManager = HTTPRequestManager()
    
    var tableView = UITableView()
    
    var configList: [Config] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        httpRequestManager.delegate = self
        
        setupTableView()

        httpRequestManager.fetchPageData()
        
        tableView.register(MerchantCouponContainerCell.self, forCellReuseIdentifier: "MerchantCouponContainerCell")
        tableView.register(PromoContainerCell.self, forCellReuseIdentifier: "PromoContainerCell")
        tableView.register(GuideContainerCell.self, forCellReuseIdentifier: "GuideContainerCell")
        tableView.register(HighlightContainerCell.self, forCellReuseIdentifier: "HighlightContainerCell")
    }
    
    func setupTableView() {
        tableView.showsVerticalScrollIndicator = false
        
        view.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension ViewController: HTTPRequestManagerDelegate {
    func manager(_ manager: HTTPRequestManager, didGet pageData: ResponsePageData) {
        
        self.configList = pageData.data.data.categories[0].config
        print(configList)
        
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
            }
            
            cell.delegate = self

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
            
            return cell
            
        } else if config.type == "GUIDE" {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "GuideContainerCell", for: indexPath) as! GuideContainerCell
            
            if let guides = config.detail.guides {
                cell.configure(with: guides)
            }
            cell.startAutoScrollTimer()

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
