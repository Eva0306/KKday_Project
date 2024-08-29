

import UIKit

protocol MerchantCouponContainerCellDelegate: AnyObject {
    func didSelectMerchantCoupon(_ coupon: MerchantCoupon)
}

class MerchantCouponContainerCell: UITableViewCell {
    
    var merchantCouponTableView = UITableView()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "超值店家優惠"
        label.textAlignment = .left
        label.font = UIFont(name: "HelveticaNeue", size: 22)
        label.textColor = .black
        return label
    }()
    
    lazy var descriptonLabel: UILabel = {
        let label = UILabel()
        label.text = "會員限定好康折扣券，專屬優惠好康不漏接"
        label.textAlignment = .left
        label.font = UIFont(name: "HelveticaNeue", size: 16)
        label.textColor = UIColor(hex: "727272")
        return label
    }()
    
    var delegate: MerchantCouponContainerCellDelegate?
    
    var merchantCouponList: [MerchantCoupon] = [] {
        didSet {
            merchantCouponTableView.reloadData()
            self.invalidateIntrinsicContentSize()
        }
    }
    
    var merchantCouponisExpanded = false
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        merchantCouponTableView.dataSource = self
        merchantCouponTableView.delegate = self
        merchantCouponTableView.isScrollEnabled = false
        
        merchantCouponTableView.register(MerchantCouponTableViewCell.self, forCellReuseIdentifier: "MerchantCouponTableViewCell")
        merchantCouponTableView.register(ShowMoreCell.self, forCellReuseIdentifier: "ShowMoreCell")
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptonLabel)
        contentView.addSubview(merchantCouponTableView)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptonLabel.translatesAutoresizingMaskIntoConstraints = false
        merchantCouponTableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            descriptonLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            descriptonLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            descriptonLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            merchantCouponTableView.topAnchor.constraint(equalTo: descriptonLabel.bottomAnchor, constant: 24),
            merchantCouponTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            merchantCouponTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            merchantCouponTableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        merchantCouponTableView.layoutIfNeeded()
        let tableViewHeight = merchantCouponTableView.contentSize.height
        
        let titleLabelHeight = titleLabel.intrinsicContentSize.height
        let descriptionLabelHeight = descriptonLabel.intrinsicContentSize.height
        
        
        let totalHeight = 24 + titleLabelHeight + 8 + descriptionLabelHeight + 24 + tableViewHeight
        
        return CGSize(width: targetSize.width, height: totalHeight)
    }
    
    func configure(with coupons: [MerchantCoupon]) {
        self.merchantCouponList = coupons
    }
}

//MARK: - Merchant Coupon TableView DataSource
extension MerchantCouponContainerCell: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 500
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if merchantCouponisExpanded || merchantCouponList.count <= 5 {
            return merchantCouponList.count
        } else {
            return 6
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if !merchantCouponisExpanded && indexPath.row == 5 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ShowMoreCell", for: indexPath) as! ShowMoreCell
            cell.setButtonTarget(target: self, action: #selector(showMoreTapped))
            let hiddenItemCount = merchantCouponList.count - 5
            cell.updateShowMoreButtonTitle(with: hiddenItemCount)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MerchantCouponTableViewCell", for: indexPath) as! MerchantCouponTableViewCell
            let coupon = merchantCouponList[indexPath.row]
            cell.updateCell(from: coupon)
            return cell
        }
    }
    
    @objc func showMoreTapped() {
        merchantCouponisExpanded = true
        merchantCouponTableView.reloadData()
        self.invalidateIntrinsicContentSize()
    }
}

//MARK: - Merchant Coupon TableView Delegate
extension MerchantCouponContainerCell: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCoupon = merchantCouponList[indexPath.row]
        delegate?.didSelectMerchantCoupon(selectedCoupon)
    }
}

