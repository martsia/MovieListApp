//
//  ViewController.swift
//  MovieListApp
//
//  Created by Marta Kalichynska on 30.01.2024.
//

import UIKit

protocol FavoritesUpdateDelegate: AnyObject {
    func didUpdateFavorites()
}

class MoviesListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, FavoritesUpdateDelegate {
    private let tableView = UITableView()
    private var viewModel = MoviesViewModel()
    
    var apiResult = [MoviesData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        fetchData()
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        tableView.addGestureRecognizer(longPressGesture)
    }
    
    func didUpdateFavorites() {
        fetchData()
    }
    
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        guard gestureRecognizer.state == .began else { return }

        let touchPoint = gestureRecognizer.location(in: tableView)

        if let indexPath = tableView.indexPathForRow(at: touchPoint) {
            let selectedMovie = apiResult[indexPath.row]
            viewModel.toggleFavoriteStatus(for: selectedMovie)
            if let movieTitle = selectedMovie.title {
                let alert = UIAlertController(title: "Added to Favorites", message: "\(movieTitle) has been added to your favorites.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                present(alert, animated: true, completion: nil)
            } else {
                print("Movie title is nil.")
                // Handle the case where the movie title is nil, if needed.
            }
        }
    }

    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MovieCell.self, forCellReuseIdentifier: "movieCell")
        tableView.backgroundColor = UIColor.black
        view.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func fetchData() {
        viewModel.fetchMoviesData { [weak self] (apiData: [MoviesData]?, error: Error?) in
            guard let self = self else { return }

            if let error = error {
                self.showAlert(title: "Error", message: "Failed to fetch movies. \(error.localizedDescription)")
            } else if let apiData = apiData {
                self.apiResult = apiData
                self.tableView.reloadData()
            }
        }
    }


    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return apiResult.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "movieCell", for: indexPath) as? MovieCell else {
            return UITableViewCell()
        }

        cell.configure(with: apiResult[indexPath.row])
        cell.contentView.backgroundColor = UIColor.black

        return cell
    }

    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 160
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "MoviesDetailViewController") as? MoviesDetailViewController {
            vc.movieId = apiResult[indexPath.row].id
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
}

