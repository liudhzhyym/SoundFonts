// Copyright © 2020 Brad Howes. All rights reserved.

#pragma once

#include <cstdlib>

namespace SF2 {

class SFGeneratorAmount {
public:
    SFGeneratorAmount() : raw_{} {}

    explicit SFGeneratorAmount(uint16_t raw) : raw_{raw} {}

    uint16_t index() const { return raw_.wAmount; }
    int16_t amount() const { return raw_.shAmount; }

    int low() const { return int(raw_.ranges[0]); }
    int high() const { return int(raw_.ranges[1]); }

    void refine(uint16_t value) { raw_.wAmount += value; }
    void refine(int16_t value) { raw_.shAmount += value; }

private:

    union {
        uint16_t wAmount;
        int16_t shAmount;
        uint8_t ranges[2];
    } raw_;
};

}
