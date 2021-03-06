// Copyright © 2020 Brad Howes. All rights reserved.

#include "../IO/File.hpp"

#include "InstrumentCollection.hpp"

using namespace SF2::Render;

InstrumentCollection::InstrumentCollection(IO::File const& file) : instruments_{}
{
    // Do *not* process the last record. It is a sentinal used only for bag calculations.
    auto count = file.instruments().size() - 1;
    instruments_.reserve(count);
    for (Entity::Instrument const& configuration : file.instruments().slice(0, count)) {
        instruments_.emplace_back(file, configuration);
    }
}
