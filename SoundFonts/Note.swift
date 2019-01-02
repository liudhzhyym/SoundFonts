//
//  Note.swift
//  SoundFonts
//
//  Created by Brad Howes on 12/18/18.
//  Copyright © 2018 Brad Howes. All rights reserved.
//

import Foundation

/**
 Definition of a MIDI note.
 */
struct Note : CustomStringConvertible, Decodable, Encodable {

    static public let sharpTag = "♯"
    static public let noteLabels: [String] = ["C", "C", "D", "D", "E", "F", "F", "G", "G", "A", "A", "B"]
    static public let solfegeLabels: [String] = ["Do", "Do", "Re", "Re", "Mi", "Fa", "Fa", "Sol", "Sol", "La", "La", "Ti"]

    /// The MIDI value to emit to generate this note
    let midiNoteValue: Int
    /// True if this note is accented (sharp or flat)
    let accented: Bool
    /// Obtain a textual representation of the note
    var label: String {
        let noteIndex = midiNoteValue % 12
        let accent = accented ? Note.sharpTag : ""
        return "\(Note.noteLabels[noteIndex])\(accent)\(octave)"
    }
    /// Obtain the solfege representation for this note
    var solfege: String {
        let noteIndex = midiNoteValue % 12
        return Note.solfegeLabels[noteIndex]
    }
    
    /// Obtain the octave this note is a part of
    var octave: Int { return midiNoteValue / 12 }

    var description: String { return label }

    /**
     Create new Note instance.
    
     - parameter midiNoteValue: MIDI note value for this instance
     */
    init(midiNoteValue: Int) {
        self.midiNoteValue = midiNoteValue
        let offset = midiNoteValue % 12
        self.accented = (offset < 5 && (offset & 1) == 1) || (offset > 5 && (offset & 1) == 0)
    }
}