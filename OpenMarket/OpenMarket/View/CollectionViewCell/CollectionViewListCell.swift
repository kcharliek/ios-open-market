import UIKit

class CollectionViewListCell: UICollectionViewListCell {
    
    enum LayoutAttribute {
        static let largeSpacing: CGFloat = 10
        static let smallSpacing: CGFloat = 5
        
        enum AcitivityIndicator {
            static let fractionalWidth: CGFloat = 0.2
            static let aspectRatio: CGFloat = 1.0
        }
        
        enum ImageView {
            static let fractionalWidth: CGFloat = 0.2
            static let aspectRatio: CGFloat = 1.0
        }
        
        enum NameLabel {
            static let fontSize: CGFloat = 17
            static let fontColor: UIColor = .black
        }
        
        enum PriceLabel {
            static let textStyle: UIFont.TextStyle = .callout
            static let originalPriceFontColor: UIColor = .red
            static let bargainPriceFontColor: UIColor = .systemGray
        }
        
        enum StockLabel {
            static let textStyle: UIFont.TextStyle = .callout
            static let stockFontColor: UIColor = .systemGray
            static let soldoutFontColor: UIColor = .orange
        }
        
        enum ChevronButton {
            static let fontColor: UIColor = .systemGray
        }
    }
    
    typealias Product = NetworkingAPI.ProductListQuery.Response.Page
    
    private let activityIndicator = UIActivityIndicatorView()
    private let imageView = UIImageView()
    private let nameLabel = UILabel()
    private let priceLabel = UILabel()
    private let labelStackView = UIStackView()
    private let stockLabel = UILabel()
    private let chevronButton = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        organizeViewHierarchy()
        configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func update(from product: Product) {
        updateImageView(from: product)
        updateNameLabel(from: product)
        updatePriceLabel(from: product)
        updateStockLabel(from: product)
    }
    
    private func organizeViewHierarchy() {
        contentView.addSubview(activityIndicator)
        contentView.addSubview(imageView)
        contentView.addSubview(labelStackView)
        contentView.addSubview(stockLabel)
        contentView.addSubview(chevronButton)
        
        labelStackView.addArrangedSubview(nameLabel)
        labelStackView.addArrangedSubview(priceLabel)
    }
    
    private func configure() {
        configureMainView()
        configureActivityIndicator()
        configureImageView()
        configureNameLabel()
        configurePriceLabel()
        configureLabelStackView()
        configureStockLabel()
        configureChevronButton()
    }

    //MARK: - MAinView
    private func configureMainView() {
        NSLayoutConstraint.activate([
            contentView.heightAnchor.constraint(greaterThanOrEqualTo: activityIndicator.heightAnchor,
                                                constant: LayoutAttribute.largeSpacing * 2),
            contentView.heightAnchor.constraint(greaterThanOrEqualTo: imageView.heightAnchor,
                                                constant: LayoutAttribute.largeSpacing * 2)
        ])
    }
}

//MARK: - ActivityIndicator
extension CollectionViewListCell {
    
    private func configureActivityIndicator() {
        activityIndicator.startAnimating()
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
                                                       constant: LayoutAttribute.largeSpacing),
            activityIndicator.widthAnchor.constraint(equalTo: contentView.widthAnchor,
                                                     multiplier: LayoutAttribute.AcitivityIndicator.fractionalWidth),
            activityIndicator.heightAnchor.constraint(equalTo: activityIndicator.widthAnchor,
                                                      multiplier: LayoutAttribute.AcitivityIndicator.aspectRatio),
            activityIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}

//MARK: - ImageView
extension CollectionViewListCell {
    
    private func configureImageView() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
                                                       constant: LayoutAttribute.largeSpacing),
            imageView.widthAnchor.constraint(equalTo: contentView.widthAnchor,
                                             multiplier: LayoutAttribute.ImageView.fractionalWidth),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor,
                                              multiplier: LayoutAttribute.ImageView.aspectRatio),
            imageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    private func updateImageView(from product: Product) {
        ImageLoader.load(from: product.thumbnail) { (result) in
            switch result {
            case .success(let data):
                DispatchQueue.main.sync {
                    self.imageView.image = UIImage(data: data)
                    self.activityIndicator.stopAnimating()
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}

//MARK: - LabelStackView
extension CollectionViewListCell {

    private func configureLabelStackView() {
        labelStackView.axis = .vertical
        labelStackView.distribution = .fillEqually

        labelStackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            labelStackView.leadingAnchor.constraint(equalTo: activityIndicator.trailingAnchor,
                                                    constant: LayoutAttribute.smallSpacing),
            labelStackView.leadingAnchor.constraint(equalTo: imageView.trailingAnchor,
                                                    constant: LayoutAttribute.smallSpacing),
            labelStackView.topAnchor.constraint(equalTo: contentView.topAnchor,
                                                constant: LayoutAttribute.largeSpacing),
            labelStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,
                                                constant: -1 * LayoutAttribute.largeSpacing)
        ])
    }
}

//MARK: - NameLabel
extension CollectionViewListCell {
    private func configureNameLabel() {
        nameLabel.adjustsFontForContentSizeCategory = true
        nameLabel.font = UIFont.dynamicBoldSystemFont(ofSize: LayoutAttribute.NameLabel.fontSize)
    }
    
    private func updateNameLabel(from product: Product) {
        nameLabel.text = product.name
    }
}

//MARK: - PriceLabel
extension CollectionViewListCell {
    
    private func configurePriceLabel() {
        priceLabel.adjustsFontForContentSizeCategory = true
    }
    
    private func updatePriceLabel(from product: Product) {
        let blank = NSMutableAttributedString(string: " ")
        let currency = NSMutableAttributedString(string: product.currency.rawValue)
        guard let originalPrice = NSMutableAttributedString(string: product.price.description).toDecimal,
              let bargainPrice = NSMutableAttributedString(string: product.bargainPrice.description).toDecimal else {
                  print(OpenMarketError.conversionFail("basic NSMutableAttributedString", "decimal").description)
                  return
              }

        let result = NSMutableAttributedString(string: "")
        if product.price != product.bargainPrice {
            let originalPriceDescription = NSMutableAttributedString()
            originalPriceDescription.append(currency)
            originalPriceDescription.append(blank)
            originalPriceDescription.append(originalPrice)
            originalPriceDescription.setStrikeThrough()
            originalPriceDescription.setFontColor(to: LayoutAttribute.PriceLabel.originalPriceFontColor)
            
            let bargainPriceDescription = NSMutableAttributedString()
            bargainPriceDescription.append(currency)
            bargainPriceDescription.append(blank)
            bargainPriceDescription.append(bargainPrice)
            bargainPriceDescription.setFontColor(to: LayoutAttribute.PriceLabel.bargainPriceFontColor)
            
            result.append(originalPriceDescription)
            result.append(blank)
            result.append(bargainPriceDescription)
        } else {
            let bargainPriceDescription = NSMutableAttributedString()
            bargainPriceDescription.append(currency)
            bargainPriceDescription.append(blank)
            bargainPriceDescription.append(bargainPrice)
            bargainPriceDescription.setFontColor(to: LayoutAttribute.PriceLabel.bargainPriceFontColor)

            result.append(bargainPriceDescription)
        }
        
        result.setTextStyle(textStyle: LayoutAttribute.PriceLabel.textStyle)
        priceLabel.attributedText = result
    }
}

//MARK: - StockLabel
extension CollectionViewListCell {
    
    private func configureStockLabel() {
        stockLabel.adjustsFontForContentSizeCategory = true
        stockLabel.font = .preferredFont(forTextStyle: LayoutAttribute.StockLabel.textStyle)
        stockLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stockLabel.topAnchor.constraint(equalTo: contentView.topAnchor,
                                            constant: LayoutAttribute.largeSpacing),
            stockLabel.trailingAnchor.constraint(equalTo: chevronButton.leadingAnchor,
                                                constant: -1 * LayoutAttribute.largeSpacing),
        ])
    }
    
    private func updateStockLabel(from product: Product) {
        if product.stock == 0 {
            stockLabel.text = "품절"
            stockLabel.textColor = LayoutAttribute.StockLabel.soldoutFontColor
        } else {
            stockLabel.text = "잔여수량: \(product.stock)"
            stockLabel.textColor = LayoutAttribute.StockLabel.stockFontColor
        }
    }
}

//MARK: - ChevronButton
extension CollectionViewListCell {
    
    private func configureChevronButton() {
        chevronButton.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        chevronButton.tintColor = LayoutAttribute.ChevronButton.fontColor
        
        chevronButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            chevronButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,
                                                    constant: -1 * LayoutAttribute.largeSpacing),
            chevronButton.centerYAnchor.constraint(equalTo: stockLabel.centerYAnchor)
        ])
    }
}
