//
//  MoviesData.swift
//  MovieListApp
//
//  Created by Marta Kalichynska on 30.01.2024.
//

import Foundation

struct Movies: Hashable, Codable {
    let results: [MoviesData]
}

struct MoviesData: Hashable, Codable {
    let backdrop_path: String?
    let id: Int
    let original_language: String?
    let original_title: String?
    let overview: String?
    let posterPath: String?
    let releaseDate: String?
    let title: String?
}

struct MovieDetailData: Hashable, Codable {
    let genres: [Genre]?
    let id: Int
    let overview: String?
    let releaseDate: String?
    let posterPath: String?
    let title: String?
}

struct Genre: Hashable, Codable {
    let id: Int
    let name: String?
}

