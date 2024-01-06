//
//  ViewController.swift
//  BoxOffice
//
//  Created by Yeseul Jang on 13/01/23.
//

import UIKit

class ViewController: UIViewController {
    var dateCountUpForTest: Int = 20230720
    let networkManager: NetworkManager = NetworkManager()
    let refreshControl: UIRefreshControl = UIRefreshControl()
    var dataSource: UICollectionViewDiffableDataSource<Section, Item>? = nil
    private var queryParameters: [String: String] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        
        self.fetchDate()
        self.configureHierarchy()
        self.initRefreshControl()
        self.fetchBoxOfficeData(networkManager: networkManager, queryParameters: ["key": Bundle.main.API, "targetDt": "\(dateCountUpForTest)"]) {
            DispatchQueue.main.async {
                self.configureDataSource()
            }
        }
    }
    
    func createLayout() -> UICollectionViewLayout {
        let config = UICollectionLayoutListConfiguration(appearance: .plain)
        return UICollectionViewCompositionalLayout.list(using: config)
    }
    
    lazy var collectionView: UICollectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
    
    func configureHierarchy() {
        collectionView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
    
    func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<CustomListCell, Item> { (cell, indexPath, item) in
            cell.updateWithItem(item)
            cell.accessories = [.disclosureIndicator()]
        }
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView, cellProvider: { (collectionView, indexPath, item) -> UICollectionViewCell in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        })
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.main])
        snapshot.appendItems(Item.all)
        guard let dataSource = dataSource else { return }
        dataSource.apply(snapshot)
    }
}

extension ViewController {
    func printBoxOfficeData() {
        do {
            
            let endPoint = EndPoint(
                baseURL: "http://www.kobis.or.kr/kobisopenapi/webservice/rest/boxoffice/searchDailyBoxOfficeList.json",
                queryItems: [
                    "key": "d4bb1f8d42a3b440bb739e9d49729660",
                    "targetDt": "20230724"
                ]
            )
            
            let url = try endPoint.generateURL(isFullPath: false)
            
            let urlRequest = URLRequest(url: url)
            
            let networkManager = NetworkManager()
            networkManager.getBoxOfficeData(requestURL: urlRequest) { (boxOffice: BoxOffice) in
                print(boxOffice)
            }
            
        } catch {
            print(error.localizedDescription)
        }
    }
}

extension ViewController {
    func fetchBoxOfficeData(completion: @escaping () -> ()) {
        do {
            let endPoint = EndPoint(
                baseURL: "http://www.kobis.or.kr/kobisopenapi/webservice/rest/boxoffice/searchDailyBoxOfficeList.json",
                queryItems: [
                    "key": "d4bb1f8d42a3b440bb739e9d49729660",
                    "targetDt": "\(dateCountUpForTest)"
                ]
            )
            
            let url = try endPoint.generateURL(isFullPath: false)
            
            let urlRequest = URLRequest(url: url)
    
            networkManager.getBoxOfficeData(requestURL: urlRequest) { (boxOffice: BoxOffice) in
                let count = boxOffice.boxOfficeResult.dailyBoxOfficeList.count
                for index in 0...(count-1) {
                    let rankNumber = boxOffice.boxOfficeResult.dailyBoxOfficeList[index].rankNumber
                    let rankIntensity = boxOffice.boxOfficeResult.dailyBoxOfficeList[index].rankIntensity
                    let movieName = boxOffice.boxOfficeResult.dailyBoxOfficeList[index].movieName
                    let audienceCount = boxOffice.boxOfficeResult.dailyBoxOfficeList[index].audienceCount
                    let audienceAccumulated = boxOffice.boxOfficeResult.dailyBoxOfficeList[index].audienceAccumulated
                    let rankOldAndNew = boxOffice.boxOfficeResult.dailyBoxOfficeList[index].rankOldAndNew
                    let movieCode = boxOffice.boxOfficeResult.dailyBoxOfficeList[index].movieCode
                    
                    let items = Item(rankNumber: rankNumber, rankIntensity: rankIntensity, movieName: movieName, audienceCount: audienceCount, audienceAccumulated: audienceAccumulated, rankOldAndNew: rankOldAndNew, movieCode: movieCode)
                    
                    Item.all.append(items)
                }
                completion()
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}

extension ViewController {
    private func initRefreshControl() {
        refreshControl.addTarget(self, action: #selector(pullRefreshControl), for: .valueChanged)
        collectionView.refreshControl = refreshControl
    }
    
    @objc func pullRefreshControl() {
        self.dateCountUpForTest += 1
        Item.all.removeAll()
        fetchBoxOfficeData {
            DispatchQueue.main.async {
                var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
                snapshot.appendSections([.main])
                snapshot.appendItems(Item.all)
                guard let dataSource = self.dataSource else { return }
                dataSource.apply(snapshot)
                
                self.refreshControl.endRefreshing()
            }
        }
    }
}

extension ViewController {
    private func fetchDate() {
        do {
            self.navigationItem.title = try DateFormatter().changeDateFormat(Date(), DateFormatter.DateFormat.hyphen)
        } catch {
            print(error.localizedDescription)
        }
    }
}

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let selectedMovieCode = dataSource?.itemIdentifier(for: indexPath)?.movieCode else { return }
        
        let detailViewController = DetailViewController(selectedMovieCode: selectedMovieCode )
        navigationController?.pushViewController(detailViewController, animated: true)
    }
}

extension ViewController: NetworkConfigurable, Fetchable {
    var baseURL: String {
         return "http://www.kobis.or.kr/kobisopenapi/webservice/rest/boxoffice/searchDailyBoxOfficeList.json"
    }
    
    var queryItems: [String : String]? {
        get {
            return self.queryParameters
        }
        set {
            guard let newValue = newValue else { return }
            self.queryParameters = newValue
        }
    }
    
    var headerParameters: [String : String]? {
        [:]
    }
}
