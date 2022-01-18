import UIKit

private enum Stock {
    static let soldOut = "품절"
    static let remainingTitle = "잔여수량 :"
}

struct AttributedTextCreator {
    static func createPriceText(product: ProductDetail?) -> NSMutableAttributedString? {
        guard let product = product else {
            return nil
        }
        
        guard let price = product.price.formattedToDecimal,
              let bargainPrice = product.bargainPrice.formattedToDecimal else {
            return nil
        }
        
        let priceAttributedText = NSMutableAttributedString()
        let spacing = " "
        
        if product.discountedPrice == 0 {
            return NSMutableAttributedString.normalStyle(string: "\(product.currency.unit) \(price)")
        }
        
        priceAttributedText.append(NSMutableAttributedString.strikeThroughStyle(string: "\(product.currency.unit) \(price)"))
        priceAttributedText.append(NSMutableAttributedString.normalStyle(string: spacing))
        priceAttributedText.append(NSMutableAttributedString.normalStyle(string: "\(product.currency.unit) \(bargainPrice)"))
        
        return priceAttributedText
    }
    
    static func createStockText(product: ProductDetail?) -> NSMutableAttributedString? {
        let soldOut = Stock.soldOut
        
        guard let product = product else {
            return nil
        }
        
        if product.stock == 0 {
            let attributedString = NSMutableAttributedString(string: soldOut)
            attributedString.addAttribute(.foregroundColor, value: UIColor.orange, range: NSRange(location: 0, length: soldOut.count))
            
            return attributedString
        }
        
        return NSMutableAttributedString.normalStyle(string: "\(Stock.remainingTitle) \(product.stock)")
    }
}
