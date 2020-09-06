// Copyright © 2020 Brad Howes. All rights reserved.

#ifndef Tag_hpp
#define Tag_hpp

#include <string>

namespace SF2 {

/**
 Each RIFF chunk or blob has a 4-character tag that uniquely identifies the contents of the chunk. This is also a 4-byte
 integer.
 */
class Tag {
public:
    Tag(uint32_t tag) : tag_{tag} {}

    bool operator ==(Tag const& rhs) const { return tag_ == rhs.tag_; }
    bool operator !=(Tag const& rhs) const { return tag_ != rhs.tag_; }

    std::string toString() const { return std::string(reinterpret_cast<char const*>(&tag_), 4); }

private:
    uint32_t tag_;
};

inline constexpr uint32_t Pack4Chars(char const* c)
{
    return ((uint32_t)(c[3])) << 24 | ((uint32_t)(c[2])) << 16 | ((uint32_t)(c[1])) << 8 | ((uint32_t)(c[0]));
}

enum Tags {
    riff = Pack4Chars("RIFF"),
    list = Pack4Chars("LIST"),
    sfbk = Pack4Chars("sfbk"),
    info = Pack4Chars("INFO"),
    sdta = Pack4Chars("sdta"),

    pdta = Pack4Chars("pdta"),
    ifil = Pack4Chars("ifil"),
    isng = Pack4Chars("isng"),
    inam = Pack4Chars("INAM"),
    irom = Pack4Chars("irom"),  // info ids (1st byte of info strings

    iver = Pack4Chars("iver"),
    icrd = Pack4Chars("ICRD"),
    ieng = Pack4Chars("IENG"),
    iprd = Pack4Chars("IPRD"),  // more info ids
    icop = Pack4Chars("ICOP"),

    icmt = Pack4Chars("ICMT"),
    isft = Pack4Chars("ISFT"),  // and yet more info ids
    snam = Pack4Chars("snam"),
    smpl = Pack4Chars("smpl"),  // sample IDs
    phdr = Pack4Chars("phdr"),

    pbag = Pack4Chars("pbag"),
    pmod = Pack4Chars("pmod"),
    pgen = Pack4Chars("pgen"),  // preset IDs
    inst = Pack4Chars("inst"),
    ibag = Pack4Chars("ibag"),

    imod = Pack4Chars("imod"),
    igen = Pack4Chars("igen"),  // instrument IDs
    shdr = Pack4Chars("shdr"),  // sample info
    sm24 = Pack4Chars("sm24"),
    unkn = Pack4Chars("????"),
};

}

#endif /* Tag_hpp */
