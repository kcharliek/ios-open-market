import UIKit

class ProductsTableViewController: UITableViewController {
    private let loadingActivityIndicator = UIActivityIndicatorView()
    private let reuseIdentifier = "productsListCell"
    private var productsList: ProductsList?
    private let jsonParser: JSONParser = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SS"
        let jsonParser = JSONParser(
            dateDecodingStrategy: .formatted(formatter),
            keyDecodingStrategy: .convertFromSnakeCase,
            keyEncodingStrategy: .convertToSnakeCase
        )
        return jsonParser
    }()
    private lazy var networkTask = NetworkTask(jsonParser: jsonParser)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startActivityIndicator()
        let nibName = UINib(nibName: "ProductsTableViewCell", bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: reuseIdentifier)
        loadProductsList()
        
    }
    
    private func startActivityIndicator() {
        view.addSubview(loadingActivityIndicator)
        loadingActivityIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingActivityIndicator.centerYAnchor.constraint(
            equalTo: view.centerYAnchor
        ).isActive = true
        loadingActivityIndicator.centerXAnchor.constraint(
            equalTo: view.centerXAnchor
        ).isActive = true
        loadingActivityIndicator.startAnimating()
    }
    
    private func loadProductsList() {
        networkTask.requestProductList(pageNumber: 1, itemsPerPage: 20) { result in
            switch result {
            case .success(let data):
                self.productsList = try? self.jsonParser.decode(from: data)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.loadingActivityIndicator.stopAnimating()
                }
            case .failure(let error):
                let alert = UIAlertController(
                    title: "Network error",
                    message: "데이터를 불러오지 못했습니다.\n\(error.localizedDescription)",
                    preferredStyle: .alert
                )
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
                self.loadingActivityIndicator.stopAnimating()
            }
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productsList?.pages.count ?? 0
    }
    
    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: reuseIdentifier,
            for: indexPath
        ) as? ProductsTableViewCell,
              let product = productsList?.pages[indexPath.row],
              let url = URL(string: product.thumbnail),
              let imageData = try? Data(contentsOf: url) else {
                  let cell = tableView.dequeueReusableCell(
                    withIdentifier: reuseIdentifier,
                    for: indexPath
                  )
                  return cell
              }
        let image = UIImage(data: imageData)
        cell.productImageView.image = image
        cell.titleLabel.attributedText = product.attributedTitle
        cell.priceLabel.attributedText = product.attributedPrice
        cell.stockLabel.attributedText = product.attributedStock
        return cell
    }
}
