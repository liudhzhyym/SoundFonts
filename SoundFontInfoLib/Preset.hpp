// Copyright © 2020 Brad Howes. All rights reserved.

#pragma once

#include "Instrument.hpp"
#include "SFFile.hpp"
#include "Zone.hpp"

namespace SF2 {

class PresetZone : public Zone {
public:
    PresetZone(SFFile const& file, InstrumentCollection const& instruments, SFBag const& bag) :
    Zone(file.presetZoneGenerators.slice(bag.generatorIndex(), bag.generatorCount()),
         file.presetZoneModulators.slice(bag.modulatorIndex(), bag.modulatorCount()),
         SFGenIndex::instrument),
    instrument_{isGlobal() ? nullptr : &instruments.at(resourceLink())}
    {}

    void refine(Configuration& configuration) const { Zone::refine(configuration); }

    Instrument const& instrument() const { assert(instrument_ != nullptr); return *instrument_; }

private:
    Instrument const* instrument_;
};

class Preset {
public:
    using PresetZoneCollection = ZoneCollection<PresetZone>;

    struct ZonePair {
        PresetZone const& presetZone;
        PresetZone const* presetGlobal;
        InstrumentZone const& instrumentZone;
        InstrumentZone const* instrumentGlobal;

        ZonePair(PresetZone const& pz, PresetZone const* pg, InstrumentZone const& iz, InstrumentZone const* ig)
        : presetZone{pz}, presetGlobal{pg}, instrumentZone{iz}, instrumentGlobal{ig} {}

        void apply(Configuration& configuration) {

            // Instrument first for override absolute values
            if (instrumentGlobal != nullptr) instrumentGlobal->apply(configuration);
            instrumentZone.apply(configuration);

            // Preset values only refine those from instrument
            if (presetGlobal != nullptr) presetGlobal->refine(configuration);
            presetZone.refine(configuration);
        }
    };

    using Matches = std::vector<ZonePair>;

    Preset(SFFile const& file, InstrumentCollection const& instruments, SFPreset const& cfg) :
    cfg_{cfg},
    zones_{size_t(cfg_.zoneCount())}
    {
        for (SFBag const& bag : file.presetZones.slice(cfg_.zoneIndex(), cfg_.zoneCount())) {
            if (bag.generatorCount() != 0 || bag.modulatorCount() != 0) {
                zones_.emplace_back(file, instruments, bag);
            }
        }
    }

    Matches find(int key, int velocity) const {
        Matches zonePairs;
        for (PresetZone const& presetZone : zones_.find(key, velocity)) {
            Instrument const& instrument = presetZone.instrument();
            InstrumentZone const* instrumentGlobal = instrument.globalZone();
            for (InstrumentZone const& instrumentZone : instrument.find(key, velocity)) {
                zonePairs.emplace_back(presetZone, globalZone(), instrumentZone, instrumentGlobal);
            }
        }

        return zonePairs;
    }

    bool hasGlobalZone() const { return zones_.hasGlobal(); }
    PresetZone const* globalZone() const { return zones_.global(); }
    SFPreset const& configuration() const { return cfg_; }

private:
    SFPreset const& cfg_;
    PresetZoneCollection zones_;
};

class PresetCollection
{
public:
    PresetCollection(SFFile const& file, InstrumentCollection const& instruments) :
    presets_{}
    {
        // Do *not* process the last record. It is a sentinal used only for bag calculations.
        auto count = file.presets.size() - 1;
        presets_.reserve(count);
        for (SFPreset const& configuration : file.presets.slice(0, count)) {
            presets_.emplace_back(file, instruments, configuration);
        }
    }

    Preset const& at(size_t index) const { return presets_.at(index); }

private:
    std::vector<Preset> presets_;
};

}
