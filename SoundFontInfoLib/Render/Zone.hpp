// Copyright © 2020 Brad Howes. All rights reserved.

#pragma once

#include <functional>
#include <vector>

#include "../Entity/Bag.hpp"
#include "../Entity/Generator.hpp"
#include "../Entity/Modulator.hpp"

#include "../IO/ChunkItems.hpp"
#include "../IO/File.hpp"

#include "Configuration.hpp"

namespace SF2 {
namespace Render {

class Zone
{
public:
    using GeneratorCollection = IO::ChunkItems<Entity::Generator>::ItemRefCollection;
    using ModulatorCollection = IO::ChunkItems<Entity::Modulator>::ItemRefCollection;

    class Range
    {
    public:
        Range(int low, int high) : low_{low}, high_{high} {}

        explicit Range(Entity::GeneratorAmount const& range) : low_{range.low()}, high_{range.high()} {}

        bool contains(int value) const { return value >= low_ && value <= high_; }

        int low() const { return low_; }
        int high() const { return high_; }

    private:
        int low_;
        int high_;
    };

    Range const& keyRange() const { return keyRange_; }
    Range const& velocityRange() const { return velocityRange_; }

    GeneratorCollection const& generators() const { return generators_; }
    ModulatorCollection const& modulators() const { return modulators_; }

protected:
    static Range const all;

    static Range KeyRange(GeneratorCollection const& gens)
    {
        if (gens.size() > 0 && gens[0].get().index() == Entity::GenIndex::keyRange) return Range(gens[0].get().value());
        return all;
    }

    static Range VelRange(GeneratorCollection const& gens)
    {
        if (gens.size() > 0 && gens[0].get().index() == Entity::GenIndex::velRange) return Range(gens[0].get().value());
        if (gens.size() > 1 && gens[0].get().index() == Entity::GenIndex::velRange) return Range(gens[1].get().value());
        return all;
    }

    static bool IsGlobal(GeneratorCollection const& gens, Entity::GenIndex expected, ModulatorCollection const& mods)
    {
        return (gens.empty() && !mods.empty()) || (!gens.empty() && gens.back().get().index() != expected);
    }

    Zone(GeneratorCollection&& gens, ModulatorCollection&& mods, Entity::GenIndex terminal) :
    generators_{gens},
    modulators_{mods},
    isGlobal_{IsGlobal(gens, terminal, mods)},
    keyRange_{KeyRange(gens)}, velocityRange_{VelRange(gens)}
    {}

    void apply(Configuration& cfg) const
    {
        std::for_each(generators_.begin(), generators_.end(), [&](Entity::Generator const& gen) { cfg[gen.index()] = gen.value(); });
    }

    void refine(Configuration& cfg) const
    {
        std::for_each(generators_.begin(), generators_.end(), [&](Entity::Generator const& gen) {
            if (gen.definition().isAdditiveInPreset()) cfg[gen.index()].refine(gen.value().amount());
        });
    }

public:

    bool appliesTo(int key, int velocity) const {
        assert(!isGlobal_);
        return keyRange_.contains(key) && velocityRange_.contains(velocity);
    }

    bool isGlobal() const { return isGlobal_; }

    uint16_t resourceLink() const {
        assert(!isGlobal_);
        return generators_.back().get().value().index();
    }

private:
    GeneratorCollection generators_;
    ModulatorCollection modulators_;

    Range keyRange_;
    Range velocityRange_;
    bool isGlobal_;
};

/**
 Templated collection of zones. A non-global zone defines a range of MIDI keys and/or velocities over which it operates. The first zone can be a `global` zone.
 The global zone defines the configuration settings that apply to all other zones.
 */
template <typename Kind>
class ZoneCollection : public std::vector<Kind>
{
public:
    using Element = Kind;
    using Super = typename std::vector<Kind>;
    using Matches = typename std::vector<std::reference_wrapper<Kind const>>;

    /**
     Construct a new collection that expects to hold the given number of elements.
     */
    explicit ZoneCollection(size_t size) : Super() { this->reserve(size); }

    /**
     Locate the zone(s) that match the given key/velocity pair.
     */
    Matches find(int key, int velocity) const {
        Matches matches;
//        typename Super::const_iterator pos = this->begin();
//        if (this->hasGlobal()) ++pos;
//        std::copy_if(pos, this->end(), std::back_inserter(matches), [=](Zone const& zone) {
//            return zone.appliesTo(key, velocity);
//        });
        return matches;
    }

    bool hasGlobal() const {
        return false;
//        if (this->empty()) return false;
//        Element const& first = this->front();
//        return first.isGlobal();
    }

    Kind const* global() const { return hasGlobal() ? &this->front() : nullptr; }
};

}
}
