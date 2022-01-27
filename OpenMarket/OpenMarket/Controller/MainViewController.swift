import UIKit

class MainViewController: UIViewController {
    private enum Section: CaseIterable {
        case product
    }
    
    private enum ViewMode {
        static let list = 0
        static let grid = 1
    }
    
    let api: APIManageable = APIManager()
    
    // MARK: - Properties
    @IBOutlet private weak var segment: LayoutSegmentedControl!
    @IBOutlet private weak var listCollectionView: UICollectionView!
    @IBOutlet private weak var gridCollectionView: UICollectionView!
    
    private var productList = [ProductInformation]() {
        didSet {
            applyListSnapShot()
            applyGridSnapShot()
        }
    }
    
    private var listDataSource: UICollectionViewDiffableDataSource<Section, ProductInformation>?
    private var gridDataSource: UICollectionViewDiffableDataSource<Section, ProductInformation>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        listCollectionView.collectionViewLayout = setListCollectionViewLayout()
        gridCollectionView.collectionViewLayout = setGridCollectionViewLayout()
        
        setSegmentedControl()
        getProductData()
        setUpListCell()
        setUpGridCell()
        applyListSnapShot(animatingDifferences: false)
        applyGridSnapShot(animatingDifferences: false)
    }
    
    private func setSegmentedControl() {
        navigationItem.titleView = segment
    }
    
    private func getProductData() {
        api.requestProductList(pageNumber: 1, itemsPerPage: 800) { [weak self] result in
            switch result {
            case .success(let data):
                self?.productList = data.pages
            case .failure(let error):
                print(error)
            }
        }
    }
    
    // MARK: - List Cell
    private func setUpListCell() {
        listCollectionView.register(ListCollectionViewCell.self, forCellWithReuseIdentifier: "ListCollectionViewCell")
        
        listDataSource = UICollectionViewDiffableDataSource<Section, ProductInformation>(collectionView: listCollectionView, cellProvider: { (collectionView, indexPath, product) -> ListCollectionViewCell in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ListCollectionViewCell", for: indexPath) as? ListCollectionViewCell else {
                return ListCollectionViewCell()
            }
            cell.configureCell(with: product)
            
            return cell
        })
    }
    
    private func applyListSnapShot(animatingDifferences: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, ProductInformation>()
        snapshot.appendSections(Section.allCases)
        snapshot.appendItems(productList)
        listDataSource?.apply(snapshot, animatingDifferences: animatingDifferences)
    }
    
    private func setListCollectionViewLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(view.frame.height * 0.1))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        return layout
    }
    
    // MARK: - Grid Cell
    private func setUpGridCell() {
        gridCollectionView.register(GridCollectionViewCell.self, forCellWithReuseIdentifier: "GridCollectionViewCell")
        
        gridDataSource = UICollectionViewDiffableDataSource<Section, ProductInformation>(collectionView: gridCollectionView, cellProvider: { (collectionView, indexPath, product) -> GridCollectionViewCell in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GridCollectionViewCell", for: indexPath) as? GridCollectionViewCell else {
                return GridCollectionViewCell()
            }
            cell.configureCell(with: product)
            return cell
        })
    }
    
    private func applyGridSnapShot(animatingDifferences: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, ProductInformation>()
        snapshot.appendSections(Section.allCases)
        snapshot.appendItems(productList)
        gridDataSource?.apply(snapshot, animatingDifferences: animatingDifferences)
    }
    
    private func setGridCollectionViewLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(view.frame.height / 3))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
        group.interItemSpacing = NSCollectionLayoutSpacing.fixed(15)
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        return layout
    }
    // MARK: - IBAction Method
    @IBAction private func changeView(_ sender: LayoutSegmentedControl) {
        switch sender.selectedSegmentIndex {
        case ViewMode.list:
            listCollectionView.isHidden = false
            gridCollectionView.isHidden = true
        case ViewMode.grid:
            listCollectionView.isHidden = true
            gridCollectionView.isHidden = false
        default:
            break
        }
    }
}
