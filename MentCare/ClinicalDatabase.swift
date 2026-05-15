//
//  ClinicalDatabase.swift
//  MentCare
//
//  Created by BERKAY TURAN on 15.05.2026.
//

import Foundation

struct ClinicalDatabase {
    static let icd10Codes: [String: String] = [
        "F32.2": "Major depressive disorder, severe",
        "F60.3": "Borderline personality disorder",
        "F41.1": "Generalized anxiety disorder",
        "F20.9": "Schizophrenia, unspecified",
        "F31.9": "Bipolar disorder, unspecified",
        "F43.1": "Post-traumatic stress disorder (PTSD)",
        "F50.0": "Anorexia nervosa"
    ]
    static func searchICD10(query: String) -> [String: String] {
        guard !query.isEmpty else { return [:] }
        let lowerQuery = query.lowercased()
        return icd10Codes.filter { $0.key.lowercased().contains(lowerQuery) || $0.value.lowercased().contains(lowerQuery) }
    }

    static let maxDosages: [String: Int] = [
        "FLUOXETINE": 80,
        "PHENELZINE": 90,
        "SERTRALINE": 200,
        "LITHIUM": 1200,
        "CLONAZEPAM": 20
    ]
    

    static func validateDosage(for drug: String, dosageString: String) -> String? {
        let cleanDrug = drug.uppercased().trimmingCharacters(in: .whitespaces)

        let numericString = dosageString.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        
        guard let dosage = Int(numericString), let maxLimit = maxDosages[cleanDrug] else {
            return nil 
        }
        
        if dosage > maxLimit {
            return "OVERDOSE WARNING: Max daily limit for \(cleanDrug) is \(maxLimit)mg!"
        }
        
        return nil
    }
}
