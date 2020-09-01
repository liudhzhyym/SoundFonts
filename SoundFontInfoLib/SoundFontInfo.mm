// Copyright © 2020 Brad Howes. All rights reserved.

#include <algorithm>
#include <fstream>
#include <iostream>
#include <vector>
#include <string>

#include "Parser.hpp"
#include "SFFile.hpp"
#include "SFManager.hpp"
#include "SoundFontInfo.h"

using namespace SF2;

@implementation SoundFontInfoPatch

- (id)init:(SFPreset const &)preset {
    if (self = [super init]) {
        self.name = [NSString stringWithUTF8String:preset.name()];
        self.bank = preset.bank();
        self.patch = preset.preset();
    }

    return self;
}

@end

@implementation SoundFontInfo

- (id)init:(NSData*)contents name:(NSString*)embeddedName patches:(NSArray*)patches {
    if (self = [super init]) {
        self.contents = contents;
        self.embeddedName = embeddedName;
        self.patches = patches;
    }
    return self;
}

+ (SoundFontInfo*)load:(NSURL*)url {
    try {
        BOOL secured = [url startAccessingSecurityScopedResource];
        // TODO: use NSInputStream instead of reading everything at once
        NSData* data = [NSData dataWithContentsOfURL:url];
        if (secured) [url stopAccessingSecurityScopedResource];
        return data ? [SoundFontInfo parse:data] : nil;
    }
    catch (enum SF2::Format value) {
        return nil;
    }
}

+ (SoundFontInfo*)parse:(NSData*)data {
    try {
        auto top = SF2::Parser::parse(data.bytes, data.length);
        auto info = top.find(Tag(Tags::info));
        if (info == top.end()) return nil;

        auto inam = info->find(Tag(Tags::inam));
        if (inam == info->end()) return nil;

        NSString* embeddedName = [NSString stringWithUTF8String:inam->charPtr()];

        auto patchData = top.find(Tag(Tags::pdta));
        if (patchData == top.end()) return nil;

        auto patchHeader = patchData->find(Tag(Tags::phdr));
        if (patchHeader == patchData->end()) return nil;

        auto presetHeader = ChunkItems<SFPreset>(*patchHeader);
        NSMutableArray* patches = [NSMutableArray arrayWithCapacity:presetHeader.size()];

        for (auto it = presetHeader.begin(); it != presetHeader.end() - 1; ++it) {
            [patches addObject:[[SoundFontInfoPatch alloc] init:*it]];
        }

        [patches sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            SoundFontInfoPatch* patch1 = obj1;
            SoundFontInfoPatch* patch2 = obj2;
            if (patch1.bank < patch2.bank) return NSOrderedAscending;
            if (patch1.bank > patch2.bank) return NSOrderedDescending;
            if (patch1.patch < patch2.patch) return NSOrderedAscending;
            if (patch1.patch == patch2.patch) return NSOrderedSame;
            return NSOrderedDescending;
        }];

        return [[SoundFontInfo alloc] init:data name:embeddedName patches:patches];
    }
    catch (enum SF2::Format value) {
        return nil;
    }
}

struct Redirector {
    std::ofstream* file = nullptr;
    std::streambuf* original = nullptr;

    explicit Redirector(char const* fileName)
    {
        if (fileName != nullptr) {
            file = new std::ofstream(fileName);
            original = std::cout.rdbuf(file->rdbuf());
        }
    }

    ~Redirector() {
        if (original != nullptr) std::cout.rdbuf(original);
        if (file != nullptr) file->close();
    }
};

- (void) dump:(NSString*)fileName {
    if (self.contents == nil) return;
    Redirector redirector(fileName.UTF8String);
    auto top = SF2::Parser::parse(self.contents.bytes, self.contents.length);
    top.dump("");
}

@end
