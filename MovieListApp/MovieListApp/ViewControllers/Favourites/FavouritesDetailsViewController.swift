//
//  FavouritesDetailsViewController.swift
//  MovieListApp
//
//  Created by Marta Kalichynska on 01.02.2024.
//

import UIKit

class FavouritesDetailsViewController: UIViewController {
    var posterImageView = UIImageView()
    let titleLabel = UILabel()
    var releaseDateLabel = UILabel()
    var genreLabel = UILabel()
    var descriptionTextView = UITextView()
    
    var movieId: Int?
    private var detailViewModel = MoviesDetailViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        configureUI()
        setUpContraints()
    }
    
    private func configureUI() {
        guard let movieId = movieId else {
            showAlert(title: "Error", message: "Invalid movieId")
            return
        }

        detailViewModel.fetchMoviesData(movieId: movieId) { [weak self] (movie: MovieDetailData?, error: Error?) in
            guard let self = self else { return }

            DispatchQueue.main.async {
                if let error = error {
                    self.showAlert(title: "Error", message: "Failed to fetch movie. \(error.localizedDescription)")
                } else if let movie = movie {
                    self.setTitleLabel(with: movie.title)
                    self.setReleaseDateLabel(with: movie.releaseDate)
                    self.setDescriptionTextView(with: movie.overview)
                    self.setGenreLabel(with: movie.genres ?? [])
                    self.loadImage(from: movie.posterPath)
                }
            }
        }
      
        view.addSubview(posterImageView)
        view.addSubview(titleLabel)
        view.addSubview(releaseDateLabel)
        view.addSubview(genreLabel)
        view.addSubview(descriptionTextView)
    }
    
    private func setUpContraints() {
        posterImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        releaseDateLabel.translatesAutoresizingMaskIntoConstraints = false
        genreLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionTextView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            posterImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            posterImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            posterImageView.widthAnchor.constraint(equalToConstant: 170),
            posterImageView.heightAnchor.constraint(equalToConstant: 250),
            
            titleLabel.topAnchor.constraint(equalTo: posterImageView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: posterImageView.trailingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            releaseDateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            releaseDateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            releaseDateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            genreLabel.topAnchor.constraint(equalTo: releaseDateLabel.bottomAnchor, constant: 8),
            genreLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            genreLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            descriptionTextView.topAnchor.constraint(equalTo: posterImageView.bottomAnchor, constant: 10),
            descriptionTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            descriptionTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            descriptionTextView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20)
        ])
    
        titleLabel.textColor = .white
        releaseDateLabel.textColor = .lightGray
        genreLabel.textColor = .lightGray
        descriptionTextView.textColor = .lightGray
    }
        
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func setTitleLabel(with title: String?) {
        titleLabel.text = title
        titleLabel.textColor = .lightGray
        titleLabel.font = .boldSystemFont(ofSize: 20)
        titleLabel.textAlignment = .justified
    }
    
    private func setReleaseDateLabel(with releaseDate: String?) {
        if let releaseDate = releaseDate {
            releaseDateLabel.text = "Released: \(releaseDate)"
            releaseDateLabel.isHidden = false
        } else {
            releaseDateLabel.isHidden = true
        }
        releaseDateLabel.textColor = .lightGray
        releaseDateLabel.numberOfLines = 0
        releaseDateLabel.lineBreakMode = .byWordWrapping
    }

    private func setGenreLabel(with genres: [Genre]) {
        let genreNames = genres.compactMap { $0.name }
        let allGenres = genreNames.joined(separator: ", ")
        
        genreLabel.text = allGenres
        genreLabel.textColor = .lightGray
        genreLabel.numberOfLines = 0
        genreLabel.lineBreakMode = .byWordWrapping
    }

    private func setDescriptionTextView(with overview: String?) {
        descriptionTextView.text = overview
        descriptionTextView.isEditable = false
        descriptionTextView.textColor = .lightGray
        descriptionTextView.font = .systemFont(ofSize: 20)
        descriptionTextView.backgroundColor = .black
        descriptionTextView.textAlignment = .justified
    }
    
    private func loadImage(from posterPath: String?) {
        guard let posterPath = posterPath,
              let imageURL = URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)") else {
            posterImageView.image = UIImage(named: "placeholderImage")
            return
        }
        
        DispatchQueue.global().async {
            if let imageData = try? Data(contentsOf: imageURL) {
                DispatchQueue.main.async {
                    self.posterImageView.image = UIImage(data: imageData)
                }
            } else {
                DispatchQueue.main.async {
                    self.posterImageView.image = UIImage(named: "placeholderImage")
                }
            }
        }
    }
}
