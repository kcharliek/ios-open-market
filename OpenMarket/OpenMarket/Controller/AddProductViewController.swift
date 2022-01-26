import UIKit

class AddProductViewController: UIViewController {
    enum ProductInput {
        static var name: String?
        static var descriptions: String?
        static var price: Double?
        static var discountedPrice: Double? = 0
        static var currency: Currency = Currency.KRW
        static var stock: Int? = 0
        static var secret: String = "EE5ud*rBT9Nu38_d"
    }
    
    enum AlertMessage {
        static let title = "⚠️ 등록 정보 확인 ⚠️"
        static let invalidNameLength = "상품명 3자리 입력"
        static let priceMissed = "가격 필수 입력"
        static let invalidPriceType = "가격 숫자만 입력"
        static let invalidDiscountPriceType = "할인금액 숫자만 입력"
        static let invalidStockType = "재고 숫자만 입력"
        static let invalidDescriptionLength = "상품 상세설명 10자 이상 입력"
        static let imageMissed = "이미지 1장 이상 등록"
    }
    
    // MARK: - Property
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var productNameTextField: UITextField!
    @IBOutlet weak var productPriceTextField: UITextField!
    @IBOutlet weak var currencySegmentedControl: UISegmentedControl!
    @IBOutlet weak var discountedPriceTextField: UITextField!
    @IBOutlet weak var productStockTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var productImageStackView: UIStackView!
    @IBOutlet weak var addImageButton: UIButton!
    
    lazy var apiManager = APIManager.shared
    let imagePicker = UIImagePickerController()
    var newProductImages: [NewProductImage] = []
    var newProductInformation: NewProductInformation?
    var isButtonTapped = true
    var selectedIndex = 0
    var alertText = AlertMessage.title
    
    // MARK: - Life Cycle Method
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.topItem?.title = "상품등록"
        setupImagePrickerController()
        setupDescriptionTextView()
        setupKeyboardNotification()
        hideKeyboard()
    }
    
    // MARK: - IBAction Method
    @IBAction func tapCancelButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    @IBAction func tapAddImageButton(_ sender: UIButton) {
        isButtonTapped = true
        showSelectImageAlert()
    }
    
    @IBAction func tapProductImage(_ sender: UIButton) {
        isButtonTapped = false
        selectedIndex = sender.tag
        showSelectImageAlert()
    }
    
    @IBAction func tapDoneButton(_ sender: UIBarButtonItem) {
        createNewProduct()
        addToProductImages()
        guard let information = newProductInformation else {
            self.invalidInputAlert(with: alertText)
            alertText = AlertMessage.title
            return
        }

        apiManager.addProduct(information: information, images: newProductImages) { result in
            switch result {
            case .success(let data):
                print("\(data.name) post 성공")
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func initializeProductInput() {
        ProductInput.name = nil
        ProductInput.descriptions = nil
        ProductInput.price = nil
        ProductInput.discountedPrice = 0
        ProductInput.stock = 0
    }
}

extension AddProductViewController {
    // MARK: - Create Data To Post
    func createNewProduct() {
        newProductInformation = nil
        initializeProductInput()
        checkInputs()
        guard let name = ProductInput.name, let price = ProductInput.price, let description = ProductInput.descriptions, let discountedPrice = ProductInput.discountedPrice, let stock = ProductInput.stock else {
            return
        }
        newProductInformation = NewProductInformation(name: name, descriptions: description, price: price, discountedPrice: discountedPrice, currency: ProductInput.currency, stock: stock, secret: ProductInput.secret)
    }
    
    func checkInputs() {
        checkProductName()
        checkProductPrice()
        checkCurrency()
        checkDiscountPrice()
        checkProductStock()
        checkProductDescription()
    }
    
    func checkProductName() {
        guard let productName = productNameTextField.text, productName.count >= 3 else {
            ProductInput.name = nil
            alertText.appendWithLineBreak(contentsOf: AlertMessage.invalidNameLength)
            return
        } // 3자리이상입력
        ProductInput.name = productName
    }
    
    func checkProductPrice() {
        guard let productPriceText = productPriceTextField.text, !productPriceText.isEmpty else {
            ProductInput.price = nil
            alertText.appendWithLineBreak(contentsOf: AlertMessage.priceMissed)
            return
        } // 필수입력
        guard let productPrice = Double(productPriceText) else {
            ProductInput.price = nil
            alertText.appendWithLineBreak(contentsOf: AlertMessage.invalidPriceType)
            return
        } // 숫자만 입력
        ProductInput.price = productPrice
    }
    
    func checkCurrency() {
        let selectedIndex = currencySegmentedControl.selectedSegmentIndex
        guard let currentTitle = currencySegmentedControl.titleForSegment(at: selectedIndex),
              let currency = Currency.init(unit: currentTitle)
        else { return }
        ProductInput.currency = currency
    }
    
    func checkDiscountPrice() {
        guard let discountPriceText = discountedPriceTextField.text, !discountPriceText.isEmpty else { return } // default 사용
        
        guard let discountPrice = Double(discountPriceText) else {
            ProductInput.discountedPrice = nil
            alertText.appendWithLineBreak(contentsOf: AlertMessage.invalidDiscountPriceType)
            return
        } // 숫자만 입력
        ProductInput.discountedPrice = discountPrice
    }
    
    func checkProductStock() {
        guard let productStockText = productStockTextField.text, !productStockText.isEmpty else { return } // default 사용
        guard let productStock = Int(productStockText) else {
            ProductInput.stock = nil
            alertText.appendWithLineBreak(contentsOf: AlertMessage.invalidStockType)
            return
        } // 숫자만 입력
        ProductInput.stock = productStock
    }
    
    func checkProductDescription() {
        guard let productDescription = descriptionTextView.text,
              descriptionTextView.textColor == UIColor.black,
              productDescription.count >= 10 else {
                  alertText.appendWithLineBreak(contentsOf: AlertMessage.invalidDescriptionLength)
                  return
              } // 필수입력 10자 이상
        ProductInput.descriptions = productDescription
    }
    
    func addToProductImages() {
        let lastTagNumber = productImageStackView.subviews.count - 1
        guard lastTagNumber >= 1 else {
            alertText.appendWithLineBreak(contentsOf: AlertMessage.imageMissed)
            return
        }
        
        for buttonTag in 1...lastTagNumber {
            getProductImageFromButton(with: buttonTag)
        }

    }
    
    func getProductImageFromButton(with tag: Int) {
        guard let imageButton = view.viewWithTag(tag) as? UIButton,
              let image = imageButton.imageView?.image,
              let imageData = image.jpegData(compressionQuality: 0.1) else { return }
        
        let productImage = NewProductImage(image: imageData)
        newProductImages.append(productImage)
    }
}

extension AddProductViewController {
    // MARK: - Image Picker Alert Method
    func showSelectImageAlert() {
        let alert = createSelectImageAlert()
        present(alert, animated: true, completion: nil)
    }
    
    func createSelectImageAlert() -> UIAlertController {
        let alert = UIAlertController(title: "상품사진 선택", message: nil, preferredStyle: .actionSheet)
        let photoLibrary = UIAlertAction(title: "사진앨범", style: .default) { action in
            self.openPhotoLibrary()
        }
        let camera = UIAlertAction(title: "카메라", style: .default) { action in
            self.openCamera()
        }
        let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        alert.addAction(photoLibrary)
        alert.addAction(camera)
        alert.addAction(cancel)
        
        return alert
    }
    
    func openPhotoLibrary() {
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: false, completion: nil)
    }
    
    func openCamera() {
        imagePicker.sourceType = .camera
        present(imagePicker, animated: false, completion: nil)
    }
}

extension AddProductViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // MARK: - Image Picker Delegate Method
    func setupImagePrickerController() {
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[.editedImage] as? UIImage {
            editProductImageStackView(with: image)
        } else if let image = info[.originalImage] as? UIImage {
            editProductImageStackView(with: image)
        }
        dismiss(animated: true, completion: nil)
    }
    
    func editProductImageStackView(with image: UIImage) {
        guard isButtonTapped else {
            changeProductImage(with: image)
            return
        }
        addProductImage(with: image)
        if productImageStackView.subviews.count == 6 {
            addImageButton.isHidden = true
        }
    }
    
    func changeProductImage(with image: UIImage) {
        guard let selectedImage = productImageStackView.subviews[selectedIndex] as? UIButton else { return }
        selectedImage.setImage(image, for: .normal)
    }
    
    func addProductImage(with image: UIImage) {
        let button = UIButton()
        button.setImage(image, for: .normal)
        button.tag = productImageStackView.subviews.count
        let lastSubviewIndex = self.productImageStackView.subviews.count - 1
        productImageStackView.insertArrangedSubview(button, at: lastSubviewIndex)
        button.addTarget(self, action: #selector(tapProductImage), for: .touchUpInside)
        button.heightAnchor.constraint(equalTo: productImageStackView.heightAnchor).isActive = true
        button.widthAnchor.constraint(equalTo: button.heightAnchor).isActive = true
    }
}
extension AddProductViewController {
    // MARK: - Text View Setup Method
    func setupDescriptionTextView() {
        setTextViewPlaceHolder()
        setTextViewOutLine()
    }
    
    func setTextViewOutLine() {
        descriptionTextView.layer.borderWidth = 0.5
        descriptionTextView.layer.borderColor = UIColor.systemGray4.cgColor
        descriptionTextView.layer.cornerRadius = 5
    }
    
    func setTextViewPlaceHolder() {
        descriptionTextView.delegate = self
        descriptionTextView.text = "상품 설명(1,000자 이내)"
        descriptionTextView.textColor = .lightGray
    }
}

extension AddProductViewController: UITextViewDelegate {
    // MARK: - Text View Delegate Method
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard let cunrrentText = descriptionTextView.text else { return true }
        let newLength = cunrrentText.count + text.count - range.length
        return newLength <= 1000
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
        
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "상품 설명(1,000자 이내)"
            textView.textColor = UIColor.lightGray
        }
    }
}

extension AddProductViewController {
    // MARK: - Keyboard Notification Setup Method
    func setupKeyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func hideKeyboard() {
        let tapEmptySpace = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapEmptySpace)
    }
    
    @objc func keyboardWillShow(_ sender: Notification) {
        let userInfo: NSDictionary = sender.userInfo! as NSDictionary
        guard let keyboardFrame: NSValue = userInfo.value(forKey: UIResponder.keyboardFrameEndUserInfoKey) as? NSValue else { return }

        let keyboardRect = keyboardFrame.cgRectValue
        scrollView.contentInset.bottom = keyboardRect.height
        scrollView.scrollIndicatorInsets = scrollView.contentInset
    }

    @objc func keyboardWillHide(_ sender: Notification) {
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension AddProductViewController {
    // MARK: - Invalid Input Alert Method
    func invalidInputAlert(with message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let close = UIAlertAction(title: "닫기", style: .cancel, handler: nil)
        alert.addAction(close)
        present(alert, animated: true)
    }
}
