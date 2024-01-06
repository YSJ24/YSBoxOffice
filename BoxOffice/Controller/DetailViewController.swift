//
//  DetailViewController.swift
//  BoxOffice
//
//  Created by Yeseul Jang on 2023/08/13.
//

import UIKit

class DetailViewController: UIViewController {
    private var selectedMovieCode: String
    private let scrollView: UIScrollView = UIScrollView()
    private let contentView: UIView = UIView()
    private let posterImageView: UIImageView = UIImageView()
    private var detailInformation: IndividualMovieDetailInformation?
    private let networkManager: NetworkManager = NetworkManager()
    
    
    init(selectedMovieCode: String) {
        self.selectedMovieCode = selectedMovieCode
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        configureScrollView()
        configureMovieposter()
        
        fetchDetailData {
            DispatchQueue.main.async {
                self.configureMovieStackView()
            }
        }
    }
    
    private func configureScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .systemBackground
        scrollView.showsVerticalScrollIndicator = false
        
        view.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            contentView.heightAnchor.constraint(equalTo: scrollView.contentLayoutGuide.heightAnchor)
        ])
    }
    
    private func configureMovieposter() {
        posterImageView.translatesAutoresizingMaskIntoConstraints = false
        posterImageView.backgroundColor = .black
        posterImageView.image = UIImage(systemName: "person")
        
        contentView.addSubview(posterImageView)
        
        NSLayoutConstraint.activate([
            posterImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            posterImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            posterImageView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.9),
            posterImageView.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor, multiplier: 2/3)
        ])
    }
    
    func configureMovieStackView() {
        let movieDetailStackView = UIStackView()
        movieDetailStackView.translatesAutoresizingMaskIntoConstraints = false
        movieDetailStackView.axis = .vertical
        movieDetailStackView.spacing = 5
        contentView.addSubview(movieDetailStackView)
        
        NSLayoutConstraint.activate([
            movieDetailStackView.topAnchor.constraint(equalTo: posterImageView.bottomAnchor, constant: 10),
            movieDetailStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            movieDetailStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -3),
            movieDetailStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        guard let detail = detailInformation else { return }
        makeStackView(categoryName: "감독", detail: detail.movieInfoResult.movieInfo.directors[0].directorName, in: movieDetailStackView)
        makeStackView(categoryName: "제작년도", detail: detail.movieInfoResult.movieInfo.productionYear, in: movieDetailStackView)
        makeStackView(categoryName: "개봉일", detail: detail.movieInfoResult.movieInfo.openDate, in: movieDetailStackView)
        makeStackView(categoryName: "상영시간", detail: detail.movieInfoResult.movieInfo.showTime, in: movieDetailStackView)
        makeStackView(categoryName: "관람등급", detail: detail.movieInfoResult.movieInfo.audits[0].watchGradeName, in: movieDetailStackView)
        makeStackView(categoryName: "제작국가", detail: detail.movieInfoResult.movieInfo.productionNations[0].productionNations, in: movieDetailStackView)
        makeStackView(categoryName: "장르", detail: detail.movieInfoResult.movieInfo.genres[0].genreName, in: movieDetailStackView)
        var actorNames: String {
            if detail.movieInfoResult.movieInfo.actors.isEmpty {
                return "없음"
            } else {
                let actorsNameInList = detail.movieInfoResult.movieInfo.actors.map { $0.peopleName }
                return actorsNameInList.joined(separator: ", ")
            }
        }
        makeStackView(categoryName: "배우", detail: actorNames, in: movieDetailStackView)
    }
    
    func makeStackView(categoryName: String, detail: String, in movieDetailStackView: UIStackView){
        let categoryLabel = UILabel()
        let detailLabel = UILabel()
        
        detailLabel.text = detail
        detailLabel.font = .preferredFont(forTextStyle: .body)
        detailLabel.numberOfLines = 0
        
        categoryLabel.text = categoryName
        categoryLabel.textAlignment = .center
        categoryLabel.font = .preferredFont(forTextStyle: .body)
        
        let stackView = UIStackView(arrangedSubviews: [categoryLabel, detailLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        
        movieDetailStackView.addArrangedSubview(stackView)
        
        NSLayoutConstraint.activate([
            categoryLabel.widthAnchor.constraint(equalTo: movieDetailStackView.widthAnchor, multiplier: 1/5)
        ])
    }
}

extension DetailViewController {
    func fetchDetailData(completion: @escaping () -> Void) {
        do {
            let endPoint = EndPoint(
                baseURL: "http://www.kobis.or.kr/kobisopenapi/webservice/rest/movie/searchMovieInfo.json",
                queryItems: ["key": Bundle.main.API ,"movieCd":selectedMovieCode]
            )
            
            let url = try endPoint.generateURL(isFullPath: false)
            
            let urlRequest = URLRequest(url: url)
            
            networkManager.getBoxOfficeData(requestURL: urlRequest) { (detail: IndividualMovieDetailInformation) in
                self.detailInformation = detail
                completion()
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}
