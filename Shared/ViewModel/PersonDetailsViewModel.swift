//
//  PersonDetailsViewModel.swift
//  Cronica
//
//  Created by Alexandre Madeira on 06/02/22.
//

import Foundation
import SwiftUI

@MainActor
class PersonDetailsViewModel: ObservableObject {
    private let service: NetworkService = NetworkService.shared
    private let persistence: PersistenceController = PersistenceController.shared
    let id: Int
    @Published var isLoaded: Bool = false
    @Published var person: Person?
    @Published var credits = [ItemContent]()
    @Published var errorMessage: String = "Error found, try again later."
    @Published var showErrorAlert: Bool = false
    @Published var query: String = ""
    @Published var isFavorite: Bool = false
    
    init(id: Int) {
        self.id = id
    }
    
    func load() async {
        if Task.isCancelled { return }
        if person == nil {
            do {
                person = try await self.service.fetchPerson(id: self.id)
                if let person {
                    let cast = person.combinedCredits?.cast?.filter { $0.itemIsAdult == false } ?? []
                    let crew = person.combinedCredits?.crew?.filter { $0.itemIsAdult == false } ?? []
                    let combinedCredits = cast + crew
                    if !combinedCredits.isEmpty {
                        let combined = Array(Set(combinedCredits))
                        credits = combined.sorted(by: { $0.itemPopularity > $1.itemPopularity })
                    }
                }
                withAnimation {
                    isLoaded.toggle()
                }
            } catch {
                if Task.isCancelled { return }
                person = nil
                let message = "Can't load the id \(id), with error message: \(error.localizedDescription)"
                CronicaTelemetry.shared.handleMessage(message, for: "PersonDetailsViewModel.load()")
            }
        }
    }
}
