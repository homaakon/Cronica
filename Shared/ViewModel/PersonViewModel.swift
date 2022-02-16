//
//  PersonViewModel.swift
//  Story
//
//  Created by Alexandre Madeira on 06/02/22.
//

import Foundation

@MainActor
class PersonViewModel: ObservableObject {
    private let service: NetworkService = NetworkService.shared
    @Published private(set) var phase: DataFetchPhase<Person?> = .empty
    var person: Person? {
        phase.value ?? nil
    }
    
    func load(id: Int) async {
        if Task.isCancelled { return }
        phase = .empty
        do {
            let person = try await self.service.fetchPerson(id: id)
            phase = .success(person)
        } catch {
            phase = .failure(error)
        }
    }
}