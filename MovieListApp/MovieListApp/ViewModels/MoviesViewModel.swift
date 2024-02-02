//
//  MoviesViewModel.swift
//  MovieListApp
//
//  Created by Marta Kalichynska on 30.01.2024.
//

import Alamofire

class MoviesViewModel {
    private let apiKey = "2ccc9fcb3e886fcb5f80015418735095"
    private let movieListURL = "https://api.themoviedb.org/3/movie/popular"
    
    init() {}
    
    func fetchMoviesData(handler: @escaping ([MoviesData]?, Error?) -> Void) {
        AF.request(movieListURL, method: .get, parameters: ["api_key": apiKey])
            .response { response in
                switch response.result {
                case .success(let data):
                    self.handleSuccessResponse(data: data, handler: handler)
                case .failure(let error):
                    self.handleFailureResponse(error: error, handler: handler)
                }
            }
    }
}

// MARK: - Response Handling
extension MoviesViewModel {
    private func handleSuccessResponse(data: Data?, handler: @escaping ([MoviesData]?, Error?) -> Void) {
        do {
            guard let data = data else {
                throw NSError(domain: "EmptyResponse", code: 2, userInfo: [NSLocalizedDescriptionKey: "Empty response from the server."])
            }
            
            let jsonDecoder = JSONDecoder()
            jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
            
            let movies = try jsonDecoder.decode(Movies.self, from: data)
            handler(movies.results, nil)
        } catch {
            handler(nil, error)
        }
    }
    
    private func handleFailureResponse(error: Error, handler: @escaping ([MoviesData]?, Error?) -> Void) {
        handler(nil, error)
    }
}

// MARK: - Favorites Handling
extension MoviesViewModel {
    func toggleFavoriteStatus(for movieData: MoviesData) {
        FavoritesManager.shared.toggleFavoriteStatus(for: movieData) { isFavorite in
            print("Is movie in favorites: \(isFavorite)")
        }
    }

    func isMovieFavorite(movieData: MoviesData) -> Bool {
        return FavoritesManager.shared.isMovieFavorite(movieData: movieData)
    }
}
