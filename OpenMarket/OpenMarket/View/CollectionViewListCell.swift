import UIKit

class CollectionViewListCell: UICollectionViewListCell {
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        return indicator
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "pencil")
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    private lazy var labelStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.addArrangedSubview(nameLabel)
        stackView.addArrangedSubview(priceLabel)
        return stackView
    }()
    
    private let stockLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        contentView.addSubview(activityIndicator)
        contentView.addSubview(labelStackView)
        contentView.addSubview(stockLabel)
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func updateAllComponents(from item: ProductListAsk.Response.Page) {
        imageView.image = ImageLoader.load(from: item.thumbnail)
        activityIndicator.stopAnimating()
        updateNameLabel(from: item)
        updatePriceLabel(from: item)
        updateStockLabel(from: item)
    }
    
    private func updateNameLabel(from item: ProductListAsk.Response.Page) {
        let nameText = item.name.boldFont
        nameText.addAttribute(.font, value: UIFont.preferredFont(forTextStyle: .caption1), range: NSMakeRange(0, nameText.length))
        nameLabel.attributedText = nameText
    }
    
    private func updateStockLabel(from item: ProductListAsk.Response.Page) {
        let stockText = NSMutableAttributedString(string: "")
        if item.stock == 0 {
            stockText.append("품절".yellowColor)
        } else {
            let description = "잔여수량: \(item.stock)"
            stockText.append(description.grayColor)
        }
        
        stockText.addAttribute(.font, value: UIFont.preferredFont(forTextStyle: .caption2), range: NSMakeRange(0, stockText.length))
        stockLabel.attributedText = stockText
    }
    
    private func updatePriceLabel(from item: ProductListAsk.Response.Page) {
        guard let bargainPrice = item.bargainPrice.description.decimal,
              let originalPrice = item.price.description.decimal else {
                  return
              }
        
        let priceText = NSMutableAttributedString(string: "")
        
        if item.price != item.bargainPrice {
            priceText.append("\(item.currency) \(originalPrice)".redStrikeThroughStyle)
            priceText.append(NSAttributedString(string: " "))
            priceText.append("\(item.currency) \(bargainPrice)".grayColor)
        } else {
            priceText.append("\(item.currency) \(originalPrice)".grayColor)
        }
        
        priceText.addAttribute(.font, value: UIFont.preferredFont(forTextStyle: .caption2), range: NSMakeRange(0, priceText.length))
        priceLabel.attributedText = priceText
    }
    
    private func configureLayout() {
        activityIndicator.bounds = contentView.bounds
        imageView.translatesAutoresizingMaskIntoConstraints = false
        labelStackView.translatesAutoresizingMaskIntoConstraints = false
        stockLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            imageView.trailingAnchor.constraint(equalTo: labelStackView.leadingAnchor, constant: -5),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            imageView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 1/6),
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor)
        ])
        NSLayoutConstraint.activate([
            labelStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            labelStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5)
        ])
        NSLayoutConstraint.activate([
            stockLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            stockLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            stockLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
        ])
    }
}
