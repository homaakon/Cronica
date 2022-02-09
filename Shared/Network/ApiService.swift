//
//  ApiService.swift
//  Story
//
//  Created by Alexandre Madeira on 22/01/22.
//

import Foundation

protocol ApiService {
    func fetchMovies(from endpoint: MovieEndpoints) async throws -> [Movie]
    func fetchTvShows(from endpoint: SeriesEndpoint) async throws -> [TvShow]
    func fetchMovie(id: Int) async throws -> Movie
    func fetchTvShow(id: Int) async throws -> TvShow
    func fetchMovieSearch(query: String) async throws -> [Movie]
    func fetchCast(id: Int) async throws -> Cast
}
