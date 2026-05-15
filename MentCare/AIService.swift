//
//  AIService.swift
//  MentCare
//
//  Created by BERKAY TURAN on 15.05.2026.
//

import Foundation
import NaturalLanguage

struct AIService {
    static func analyzeRisk(from text: String) -> String {
        let lowercasedText = text.lowercased()
        let suicidalKeywords = [
            "suicide", "kill myself", "end it all", "better off dead", "want to die",
            "hopeless", "worthless", "no reason to live", "ready to give up", "overdose",
            "hang myself", "slit my", "nothing matters", "make the pain stop",
            "tired of living", "don't want to wake up", "self-harm", "take my own life",
            "swallow pills", "jump off", "pointless existence", "severe depression"
        ]
        
        // Çevreye zarar verme, şiddet ve düşmanlık belirtileri
        let aggressiveKeywords = [
            "attack", "hurt someone", "kill him", "kill her", "kill them", "punch",
            "destroy", "revenge", "violent urge", "stab", "shoot", "smash", "murder",
            "beat them", "uncontrollable rage", "threaten", "break things", "lose control",
            "want to hurt", "make them pay", "aggressive behavior", "hostile"
        ]
        
        for phrase in suicidalKeywords {
            if lowercasedText.contains(phrase) { return "Suicidal" }
        }
        
        for phrase in aggressiveKeywords {
            if lowercasedText.contains(phrase) { return "Aggressive" }
        }
        let tagger = NLTagger(tagSchemes: [.sentimentScore])
        tagger.string = text
        let (sentiment, _) = tagger.tag(at: text.startIndex, unit: .paragraph, scheme: .sentimentScore)
        
        if let scoreString = sentiment?.rawValue, let score = Double(scoreString) {
            print("🧠 AI Sentiment Score: \(score)")
            if score <= -0.75 {
                return "Suicidal"
            } else if score >= 0.5 {
                return "Normal"
            }
        }
        
        return "Normal" 
    }
}
