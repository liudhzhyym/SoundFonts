// Copyright © 2020 Brad Howes. All rights reserved.

#pragma once

#include "ChunkItems.hpp"
#include "SFModList.hpp"

namespace SF2 {

/**
 Collection of SFModList entities that represents all of the mod definitions for the zones in an SF2 file.
 */
struct PresetZoneMods : ChunkItems<SFModList>
{
    using Super = ChunkItems<SFModList>;

    PresetZoneMods() : Super() {}
    
    PresetZoneMods(Chunk const& chunk) : Super(chunk) {}
};

}
