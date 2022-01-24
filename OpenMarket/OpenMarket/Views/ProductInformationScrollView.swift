//
//  ProductInformationScrollView.swift
//  OpenMarket
//
//  Created by 이차민 on 2022/01/20.
//

import UIKit

class ProductInformationScrollView: UIScrollView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        configUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    let productInformationView = ProductInformationView()
    
    func configUI() {
        self.addSubview(productInformationView)
        productInformationView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            productInformationView.topAnchor.constraint(equalTo: self.topAnchor),
            productInformationView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            productInformationView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            productInformationView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            productInformationView.widthAnchor.constraint(equalTo: self.widthAnchor)
        ])
    }
}
