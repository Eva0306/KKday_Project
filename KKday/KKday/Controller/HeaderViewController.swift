//
//  ViewController.swift
//  KKday
//
//  Created by Vickyhereiam on 2024/8/23.
//
import UIKit

class HeaderViewController: UIViewController, CountrySelectorViewDelegate, HTTPRequestManagerDelegate {
    
    var selectedCountry: Category?
    var countries: [Category] = []
    
    let requestManager = HTTPRequestManager()
    var countrySelectorView: CountrySelectorView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        requestManager.delegate = self
        requestManager.fetchPageData()
    }
    
    func setupUI() {
        let titleLabel = UILabel()
        titleLabel.text = "優惠專區"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 22)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        var config = UIButton.Configuration.plain()
        config.title = "國家"
        config.baseForegroundColor = .black
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                    var outgoing = incoming
                    outgoing.font = UIFont.systemFont(ofSize: 16, weight: .light)
                    return outgoing
                }
        if let originalImage = UIImage(systemName: "chevron.down") {
            let smallerSize = CGSize(width: 12, height: 6)
            let renderer = UIGraphicsImageRenderer(size: smallerSize)
            
            let smallerImage = renderer.image { _ in
                originalImage.draw(in: CGRect(origin: .zero, size: smallerSize))
            }
            
            config.image = smallerImage
        }
        config.imagePadding = 8
        config.imagePlacement = .trailing
        config.baseBackgroundColor = .white
        config.background.strokeColor = UIColor.lightGray
        config.background.strokeWidth = 1.0
        config.background.cornerRadius = 15.0
        config.contentInsets = NSDirectionalEdgeInsets(top: 6.0, leading: 12.0, bottom: 6.0, trailing: 12.0)
        
        let dropdownButton = UIButton(configuration: config, primaryAction: nil)
        dropdownButton.translatesAutoresizingMaskIntoConstraints = false
        dropdownButton.addTarget(self, action: #selector(showCountrySelector), for: .touchUpInside)
        view.addSubview(dropdownButton)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 80),

            dropdownButton.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 8),
            dropdownButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor)
        ])
    }
    
    @objc func showCountrySelector() {
        addDarkOverlay()
        
        if countrySelectorView == nil {
            countrySelectorView = CountrySelectorView(frame: CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: 700))
            countrySelectorView?.delegate = self
            countrySelectorView?.countries = self.countries
            countrySelectorView?.selectedCountry = self.selectedCountry
            view.addSubview(countrySelectorView!)
        }
        
        UIView.animate(withDuration: 0.3) {
            self.countrySelectorView?.frame.origin.y = self.view.frame.height - 700
            self.countrySelectorView?.layoutIfNeeded()
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
    
    func didSelectCountry(_ country: Category?) {
        self.selectedCountry = country
        if let selectedCountry = country {
            print("Selected country: \(selectedCountry.name)")
        }
        hideCountrySelector()
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
    
    // MARK: - HTTPRequestManagerDelegate
    
    func manager(_ manager: HTTPRequestManager, didGet data: Any) {
        if let responsePageData = data as? ResponsePageData {
            self.countries = responsePageData.data.categories
            print("Data received: \(responsePageData)")
        }
    }
    
    func manager(_ manager: HTTPRequestManager, didFailWith error: Error) {
        print("Failed to fetch data: \(error)")
    }
}
