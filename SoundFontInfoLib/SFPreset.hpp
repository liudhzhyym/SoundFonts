// Copyright © 2020 Brad Howes. All rights reserved.

#pragma once

#include <iostream>

#include "BinaryStream.hpp"
#include "Chunk.hpp"
#include "StringUtils.hpp"

namespace SF2 {

/**
 Memory layout of 'phdr' entry in sound font. The size of this is defined to be 38 bytes, but due
 to alignment/padding the struct below is 40 bytes.
 */
class SFPreset {
public:
    constexpr static size_t size = 38;

    SFPreset() {}

    explicit SFPreset(Pos const& pos)
    {
        // Account for the extra padding by reading twice.
        pos.readInto(&achPresetName, 26).readInto(&dwLibrary, 12);
        trim_property(achPresetName);
    }
    
    explicit SFPreset(BinaryStream& is)
    {
        // Account for the extra padding by reading twice.
        is.copyInto(&achPresetName, 26);
        is.copyInto(&dwLibrary, 12);
        trim_property(achPresetName);
    }

    char const* name() const { return achPresetName; }
    uint16_t preset() const { return wPreset; }
    uint16_t bank() const { return wBank; }

    uint16_t zoneIndex() const { return wPresetBagNdx; }
    uint16_t zoneCount() const { return (this + 1)->zoneIndex() - zoneIndex(); }

    void dump(const std::string& indent, int index) const
    {
        std::cout << indent << index << ": '" << name() << "' preset: " << preset()
        << " bank: " << bank()
        << " zoneIndex: " << zoneIndex() << " count: " << zoneCount() << std::endl;
    }

private:
    char achPresetName[20];
    uint16_t wPreset;
    uint16_t wBank;
    uint16_t wPresetBagNdx;
    uint32_t dwLibrary;
    uint32_t dwGenre;
    uint32_t dwMorphology;
};

}
