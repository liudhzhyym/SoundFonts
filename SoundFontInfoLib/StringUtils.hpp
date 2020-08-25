// Copyright © 2020 Brad Howes. All rights reserved.

#pragma once

#include <string>

#include <algorithm>
#include <cctype>
#include <locale>

// trim from start (in place)
static inline void ltrim(std::string &s) {
    s.erase(s.begin(), std::find_if(s.begin(), s.end(), [](int ch) { return ch != 0 && !std::isspace(ch); }));
}

// trim from end (in place)
static inline void rtrim(std::string &s) {
    s.erase(std::find_if(s.rbegin(), s.rend(), [](int ch) { return ch != 0 && !std::isspace(ch); }).base(), s.end());
}

// trim from both ends (in place)
static inline void trim(std::string &s) {
    ltrim(s);
    rtrim(s);
    s.erase(std::find_if(s.begin(), s.end(), [](int ch) { return ch == 0; }), s.end());
}

// trim from start (copying)
static inline auto ltrim_copy(std::string s) -> auto {
    ltrim(s);
    return s;
}

// trim from end (copying)
static inline auto rtrim_copy(std::string s) -> auto {
    rtrim(s);
    return s;
}

// trim from both ends (copying)
static inline auto trim_copy(std::string s) -> auto {
    trim(s);
    return s;
}

static inline void trim_property(char* property, size_t size)
{
    std::string name(property, size - 1);
    trim(name);
    strncpy(property, name.c_str(), std::min(name.size() + 1, size));
}

template <typename T>
static inline void trim_property(T& property)
{
    trim_property(property, sizeof(property));
}
