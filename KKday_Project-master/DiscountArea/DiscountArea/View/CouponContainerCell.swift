//
//  CouponContainerCell.swift
//  DiscountArea
//
//  Created by Vickyhereiam on 2024/8/28.
//

import UIKit

class CouponContainerCell: UITableViewCell {
    
    var couponTableView = UITableView()
    
    //TODO:
    var popupView: UIView?
    
    var couponList: [Coupon] = [] {
        didSet {
            couponTableView.reloadData()
            self.invalidateIntrinsicContentSize()
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        couponTableView.dataSource = self
        couponTableView.delegate = self
        couponTableView.isScrollEnabled = false
        
        couponTableView.register(CouponTableViewCell.self, forCellReuseIdentifier: "CouponTableViewCell")
        
        contentView.addSubview(couponTableView)
        
        couponTableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            couponTableView.topAnchor.constraint(equalTo: contentView.topAnchor),
            couponTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            couponTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            couponTableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        couponTableView.layoutIfNeeded()
        let tableViewHeight = couponTableView.contentSize.height
        return CGSize(width: targetSize.width, height: tableViewHeight)
    }
    
    func configure(with coupons: [Coupon]) {
        self.couponList = coupons
    }
}

//MARK: - Merchant Coupon TableView DataSource
extension CouponContainerCell: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return couponList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CouponTableViewCell", for: indexPath) as! CouponTableViewCell
        let coupon = couponList[indexPath.row]
        cell.configure(with: coupon)
        return cell
    }
}

extension CouponContainerCell {
    
    func showPopupView() {
        let popupView = UIView()
        popupView.backgroundColor = .white
        popupView.layer.cornerRadius = 20
        popupView.layer.masksToBounds = true
        popupView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(popupView)
        
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
            popupView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            popupView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            popupView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
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
