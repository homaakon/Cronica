//
//  SeriesViewModel.swift
//  Story
//
//  Created by Alexandre Madeira on 08/02/22.
//

import Foundation

@MainActor
class SeriesViewModel: ObservableObject {
    @Published private(set) var phase: DataFetchPhase<[TvSection]> = .empty
    private let service: NetworkService = NetworkService.shared
    var sections: [TvSection] {
        phase.value ?? []
    }
    
    func loadAllEndpoints() async {
        if Task.isCancelled {
            return
        }
        if case .success = phase {
            return
        }

        phase = .empty
        
        do {
            let sections = try await fetchFromEndpoints()
            if Task.isCancelled { return }
            phase = .success(sections)
        } catch {
            if Task.isCancelled { return }
            phase = .failure(error)
        }
    }
    
    private func fetchFromEndpoints(_ endpoint: [SeriesEndpoint] = SeriesEndpoint.allCases) async throws -> [TvSection] {
        let results: [Result<TvSection, Error>] = await withTaskGroup(of: Result<TvSection, Error>.self) { group in
            for endpoint in endpoint {
                group.addTask { await self.fetchFromEndpoint(endpoint) }
            }
            var results = [Result<TvSection, Error>]()
            for await result in group {
                results.append(result)
            }
            return results
        }
        var contentSections = [TvSection]()
        var errors = [Error]()
        
        results.forEach { result in
            switch result {
            case .success(let contentSection):
                contentSections.append(contentSection)
            case .failure(let error):
                errors.append(error)
            }
        }
        
        if errors.count == results.count, let error = errors.first {
            throw error
        }
        
        return contentSections.sorted { $0.endpoint.sortIndex < $1.endpoint.sortIndex }
    }
    
    private func fetchFromEndpoint(_ endpoint: SeriesEndpoint) async -> Result<TvSection, Error> {
        do {
            let series = try await service.fetchTvShows(from: endpoint)
            return .success(.init(results: series, endpoint: endpoint))
        } catch {
            return .failure(error)
        }
    }
}
