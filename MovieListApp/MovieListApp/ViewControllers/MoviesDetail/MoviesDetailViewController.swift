//
//  MovieDetailScreen.swift
//  MovieListApp
//
//  Created by Marta Kalichynska on 31.01.2024.
//

import UIKit

class MoviesDetailViewController: UIViewController {
    
    @IBOutlet private var posterImageView: UIImageView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var releaseDateLabel: UILabel!
    @IBOutlet private var descriptionTextView: UITextView!
    
    var movieId: Int?
    private var detailViewModel = MoviesDetailViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        configureUI()
    }
    
    private func configureUI() {
        guard let movieId = movieId else {
            showAlert(title: "Error", message: "Invalid movieId")
            return
        }

        detailViewModel.fetchMoviesData(movieId: movieId) { [weak self] (movie: MovieDetailData?, error: Error?) in
            guard let self = self else { return }

            if let error = error {
                self.showAlert(title: "Error", message: "Failed to fetch movie. \(error.localizedDescription)")
            } else if let movie {
                setTitleLabel(with: movie.title)
                setReleaseDateLabel(with: movie.releaseDate)
                setDescriptionTextView(with: movie.overview)
                loadImage(from: movie.posterPath)
            }
        }
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
    }
    
    private func setReleaseDateLabel(with releaseDate: String?) {
        if let releaseDate = releaseDate {
            releaseDateLabel.text = "Release Date: \(releaseDate)"
            releaseDateLabel.font = .systemFont(ofSize: 15)
            releaseDateLabel.isHidden = false
        } else {
            releaseDateLabel.isHidden = true
        }
        releaseDateLabel.textColor = .lightGray
    }
    
    private func setDescriptionTextView(with overview: String?) {
        descriptionTextView.text = overview
        descriptionTextView.isEditable = false
        descriptionTextView.textColor = .lightGray
        descriptionTextView.font = .systemFont(ofSize: 20)
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
