//
//  MoviesDetailViewModel.swift
//  MovieListApp
//
//  Created by Marta Kalichynska on 01.02.2024.
//

import Foundation
import Alamofire

class MoviesDetailViewModel {
    private let apiKey = "2ccc9fcb3e886fcb5f80015418735095"
    
    private func getMovieUrl(movieId: Int) -> String {
        return "https://api.themoviedb.org/3/movie/\(movieId)?language=en-US"
    }
    
    func fetchMoviesData(movieId: Int, handler: @escaping (MovieDetailData?, Error?) -> Void) {
        AF.request(getMovieUrl(movieId: movieId), method: .get, parameters: ["api_key": apiKey])
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

extension MoviesDetailViewModel {
    private func handleSuccessResponse(data: Data?, handler: @escaping (MovieDetailData?, Error?) -> Void) {
        do {
            guard let data = data else {
                throw NSError(domain: "EmptyResponse", code: 2, userInfo: [NSLocalizedDescriptionKey: "Empty response from the server."])
            }
            
            let jsonDecoder = JSONDecoder()
            jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
            
            let movie = try jsonDecoder.decode(MovieDetailData.self, from: data)
            handler(movie, nil)
        } catch {
            handler(nil, error)
        }
    }
    
    private func handleFailureResponse(error: Error, handler: @escaping (MovieDetailData?, Error?) -> Void) {
        handler(nil, error)
    }
    
}
