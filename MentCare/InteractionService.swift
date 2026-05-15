//
//  InteractionService.swift
//  MentCare
//
//  Created by BERKAY TURAN on 15.05.2026.
//

import Foundation

struct InteractionService {
    static let knownInteractions: [Set<String>: String] = [
        Set(["FLUOXETINE", "PHENELZINE"]): "CRITICAL RISK: Serotonin syndrome. Do not combine SSRIs with MAOIs.",
        Set(["WARFARIN", "ASPIRIN"]): "HIGH RISK: Severely increased risk of internal bleeding.",
        Set(["CLONAZEPAM", "ALCOHOL"]): "CRITICAL RISK: Severe CNS depression and respiratory failure.",
        Set(["LITHIUM", "IBUPROFEN"]): "MODERATE RISK: NSAIDs can increase Lithium toxicity levels."
    ]

    static func checkInteractions(for drugs: [String]) -> String? {
        guard drugs.count >= 2 else { return nil }
        let uppercaseDrugs = drugs.map { $0.uppercased().trimmingCharacters(in: .whitespaces) }
        let drugSet = Set(uppercaseDrugs)
        
        for (dangerousPair, warning) in knownInteractions {
            if dangerousPair.isSubset(of: drugSet) {
                return warning
            }
        }
        
        return nil
    }
}
