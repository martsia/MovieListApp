//
//  MoviesViewModel.swift
//  MovieListApp
//
//  Created by Marta Kalichynska on 30.01.2024.
//

import Foundation
import Alamofire

class MoviesViewModel {
    static let sharedInstance = MoviesViewModel()
    
    func fetchMoviesData(handler: @escaping ([MoviesData]?, Error?) -> Void) {
        let apiKey = "2ccc9fcb3e886fcb5f80015418735095"
        let movieListURL = "https://api.themoviedb.org/3/movie/popular?api_key=\(apiKey)"
        
        AF.request(movieListURL, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil, interceptor: nil)
            .response { response in  
                switch response.result {
                case .success(let data):
                    self.handleSuccessResponse(data: data, handler: handler)
                case .failure(let error):
                    self.handleFailureResponse(error: error, handler: handler)
                }
            }
    }
    
    private func handleSuccessResponse(data: Data?, handler: @escaping ([MoviesData]?, Error?) -> Void) {
        do {
            if let data = data {
                let jsonDecoder = JSONDecoder()
                jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase

                let movies = try jsonDecoder.decode(Movies.self, from: data)
                handler(movies.results, nil)
            } else {
                handler(nil, NSError(domain: "EmptyResponse", code: 2, userInfo: [NSLocalizedDescriptionKey: "Empty response from the server."]))
            }
        } catch {
            handler(nil, error)
        }
    }
    
    private func handleFailureResponse(error: Error, handler: @escaping ([MoviesData]?, Error?) -> Void) {
        handler(nil, error)
    }
}


