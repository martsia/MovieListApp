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
    let release_date: String?
    let title: String?
}


