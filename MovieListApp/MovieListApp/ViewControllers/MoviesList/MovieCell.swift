//
//  MovieCell.swift
//  MovieListApp
//
//  Created by Marta Kalichynska on 31.01.2024.
//

import UIKit

class MovieCell: UITableViewCell {
    let movieImageView = UIImageView()
    let titleLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with movieData: MoviesData) {
        titleLabel.text = movieData.title
        titleLabel.textColor = .lightGray
        titleLabel.font = .boldSystemFont(ofSize: 20)
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.5

        if let posterPath = movieData.posterPath,
           let imageURL = URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)") {
            DispatchQueue.global().async {
                if let imageData = try? Data(contentsOf: imageURL) {
                    DispatchQueue.main.async {
                        self.movieImageView.image = UIImage(data: imageData)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.movieImageView.image = UIImage(named: "placeholderImage")
                    }
                }
                
            }
        } else {
            movieImageView.image = UIImage(named: "placeholderImage")
        }
    }
    
    private func configureCell() {
        contentView.addSubview(movieImageView)
        contentView.addSubview(titleLabel)
        
        movieImageView.contentMode = .scaleAspectFill
        movieImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            movieImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            movieImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            movieImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            movieImageView.widthAnchor.constraint(equalToConstant: 80),
            movieImageView.heightAnchor.constraint(equalToConstant: 200),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: movieImageView.trailingAnchor, constant: 16),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
        ])
    }
}
