//
//  MovieCollectionViewCell.swift
//  SimpleMovieSearch
//
//  Created by Jinyoung Kim on 2022/12/19.
//

import UIKit
import RxSwift

final class MovieCollectionViewCell: UICollectionViewCell {
    static let identifier = "MovieCollectionViewCell"
    
    let moviePosterImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let favoriteButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "star"), for: .normal)
        button.setImage(UIImage(named: "star.fill"), for: .selected)
        button.tintColor = .systemYellow
        button.backgroundColor = .white
        button.isUserInteractionEnabled = false
        return button
    }()
    
    lazy var movieTitleLabel: UILabel = configureLabel(fontSize: 17)
    lazy var movieYearLabel: UILabel = configureLabel()
    lazy var movieTypeLabel: UILabel = configureLabel()
    
    var disposeBag: DisposeBag = .init()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
        configureMovieTitleLabel()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        moviePosterImage.image = nil
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MovieCollectionViewCell {
    func update(from item: Movie) {
        favoriteButton.isSelected = item.isFavorite
        movieTitleLabel.text = item.title
        movieYearLabel.text = item.year
        movieTypeLabel.text = item.type
       
        guard let placeholderImage = UIImage(named: "no-image") else { return }
        
        guard item.poster.isValidURL,
              let url = NSURL(string: item.poster)
        else {
            moviePosterImage.image = placeholderImage
            return
        }
        
        ImageLoader.shared
            .load(url: url, cell: self)
            .observe(on: MainScheduler.instance)
            .subscribe(with: self, onNext: { owner, image in
                owner.moviePosterImage.image = image
            }, onError: { _, error in
                ErrorMessagePrinter.print(error: error)
            })
            .disposed(by: disposeBag)
    }
    
    private func configureLabel(fontSize: CGFloat = 13) -> UILabel {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: fontSize)
        return label
    }
    
    private func configureMovieTitleLabel() {
        movieTitleLabel.adjustsFontSizeToFitWidth = true
        movieTitleLabel.numberOfLines = 2
    }
    
    private func configureView() {
        let labelStackView = UIStackView()
        labelStackView.axis = .vertical
        labelStackView.distribution = .fillProportionally
        [movieTitleLabel, movieYearLabel, movieTypeLabel].forEach {
            labelStackView.addArrangedSubview($0)
        }
        
        let wholeStackView = UIStackView()
        wholeStackView.axis = .vertical
        [moviePosterImage, labelStackView].forEach {
            wholeStackView.addArrangedSubview($0)
        }
        addSubview(wholeStackView)
        
        moviePosterImage.snp.makeConstraints { make in
            make.height.equalTo(moviePosterImage.snp.width).multipliedBy(1.3)
        }
        
        wholeStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        addSubview(favoriteButton)
        
        let buttonSideLength: CGFloat = 40
        favoriteButton.snp.makeConstraints { make in
            make.width.height.equalTo(buttonSideLength)
            make.top.trailing.equalToSuperview().inset(10)
        }
        
        favoriteButton.layer.cornerRadius = buttonSideLength / 2
    }
}
