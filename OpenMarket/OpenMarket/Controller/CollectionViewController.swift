//
//  CollectionViewController.swift
//  OpenMarket
//
//  Created by 박병호 on 2022/01/11.
//

import UIKit

private enum Section: Hashable {
  case main
}

class CollectionViewController: UIViewController {
  
  @IBOutlet private weak var segmentControl: UISegmentedControl!
  @IBOutlet private weak var collectionView: UICollectionView!
  
  private var dataSource: UICollectionViewDiffableDataSource<Section, Product>? = nil
  private let api = APIManager(urlSession: URLSession(configuration: .default))
  private var products: [Product] = []
  
  let listView = 0
  let gridView = 1
  
  private lazy var activityIndicator: UIActivityIndicatorView = {
    let activityIndicator = UIActivityIndicatorView()
    activityIndicator.center = self.view.center
    activityIndicator.style = .large
    return activityIndicator
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    collectionView.delegate = self
    startIndicator()
    registerNib()
    fetchProducts()
  }
  
  @IBAction private func touchUpPresentingSegment(_ sender: UISegmentedControl) {
    switch sender.selectedSegmentIndex {
    case listView:
      configureListViewDataSource()
    case gridView:
      configureGridViewDataSource()
    default:
      return
    }
  }
  
  private func startIndicator() {
    self.view.addSubview(activityIndicator)
    activityIndicator.startAnimating()
  }
  
  private func registerNib() {
    let productCollectionViewListCellNib =  UINib(nibName: ProductCollectionViewListCell.nibName, bundle: nil)
    self.collectionView.register(productCollectionViewListCellNib, forCellWithReuseIdentifier: ProductCollectionViewListCell.reuseIdentifier)
    let productCollectionViewGridCellNib =  UINib(nibName: ProductCollectionViewGridCell.nibName, bundle: nil)
    self.collectionView.register(productCollectionViewGridCellNib, forCellWithReuseIdentifier: ProductCollectionViewGridCell.reuseIdentifier)
  }
  
  private func fetchProducts() {
    api.productList(pageNumber: 1, itemsPerPage: 20) { response in
      switch response {
      case .success(let data):
        self.products = data.pages
        DispatchQueue.main.async {
          self.configureListViewDataSource()
          self.activityIndicator.stopAnimating()
        }
      case .failure(let error):
        print(error)
      }
    }
  }
}

extension CollectionViewController {
  private func configureGridViewDataSource() {
    dataSource = UICollectionViewDiffableDataSource<Section, Product>(collectionView: collectionView) {
      (collectionView: UICollectionView, indexPath: IndexPath, item: Product) -> UICollectionViewCell? in
      guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProductCollectionViewGridCell.reuseIdentifier, for: indexPath) as? ProductCollectionViewGridCell else {
        return UICollectionViewCell()
      }
      
      guard let imageUrl = URL(string: item.thumbnail),
            let imageData = try? Data(contentsOf: imageUrl),
            let image = UIImage(data: imageData) else {
              return UICollectionViewCell()
            }
      
      cell.insertCellData(
        image: image,
        name: item.name,
        fixedPrice: item.fixedPrice,
        bargainPrice: item.getBargainPrice,
        stock: item.getStock
      )
      
      return cell
    }
    var snapshot = NSDiffableDataSourceSnapshot<Section, Product>()
    snapshot.appendSections([.main])
    snapshot.appendItems(products)
    dataSource?.apply(snapshot, animatingDifferences: false)
  }
  
  private func configureListViewDataSource() {
    dataSource = UICollectionViewDiffableDataSource<Section, Product>(collectionView: collectionView) {
      (collectionView: UICollectionView, indexPath: IndexPath, item: Product) -> UICollectionViewCell? in
      guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProductCollectionViewListCell.reuseIdentifier, for: indexPath) as? ProductCollectionViewListCell else {
        return UICollectionViewCell()
      }
      
      guard let imageUrl = URL(string: item.thumbnail),
            let imageData = try? Data(contentsOf: imageUrl),
            let image = UIImage(data: imageData) else {
              return UICollectionViewCell()
            }
      
      cell.insertCellData(
        image: image,
        name: item.name,
        fixedPrice: item.fixedPrice,
        bargainPrice: item.getBargainPrice,
        stock: item.getStock
      )
      
      return cell
    }
    var snapshot = NSDiffableDataSourceSnapshot<Section, Product>()
    snapshot.appendSections([.main])
    snapshot.appendItems(products)
    dataSource?.apply(snapshot, animatingDifferences: false)
  }
}

extension CollectionViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    sizeForItemAt indexPath: IndexPath
  ) -> CGSize {
    let width = collectionView.frame.width
    
    if segmentControl.selectedSegmentIndex == listView {
      return CGSize(width: width, height: width / 7)
    } else {
      return CGSize(width: width / 2.2, height: width / 1.55)
    }
  }
  
  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    insetForSectionAt section: Int
  ) -> UIEdgeInsets {
    if segmentControl.selectedSegmentIndex == listView {
      return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    } else {
      return UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
    }
  }
  
  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    minimumLineSpacingForSectionAt section: Int
  ) -> CGFloat {
    if segmentControl.selectedSegmentIndex == listView {
      return 5
    } else {
      return 8
    }
  }
}
