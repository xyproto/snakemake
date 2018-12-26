# CXX

[![Standard](https://img.shields.io/badge/C%2B%2B-17-blue.svg)](https://en.wikipedia.org/wiki/C%2B%2B#Standardization) [![Standard](https://img.shields.io/badge/C%2B%2B-2a-blue.svg)](https://en.wikipedia.org/wiki/C%2B%2B#Standardization) [![Build Status](https://travis-ci.org/xyproto/cxx.svg?branch=master)](https://travis-ci.org/xyproto/cxx) [![License](https://img.shields.io/badge/license-MIT-green.svg)](https://opensource.org/licenses/MIT)

Simple build system for Arch Linux, FreeBSD, Ubuntu 17.10 or macOS w/Homebrew, **for developers that just want to program in C++17 or C++20 and build one or more executables** and not have to deal with build configuration and compilation flags. Defines for directories like `img` and `data` are provided. A simple way to test and package code is also provided.

*CXX* provides a way to structure your C++ code, test and debug your source files. It also makes it easy for Linux (or Homebrew) packagers to package your project, and for users to build and install it.

For now, **CXX** uses `scons`, `make` and `pkg-config` under the hood, while providing a tool that aims to be as easy to use as `go build` for Go.

Dependencies are discovered automatically, and the correct flags are given to the C++ compiler. If the dependencies are discovered correctly, the project is *CXX*-compliant and may display the badge below as a guarantee for users that the project will be easy to deal with.

**No build-configuration files are needed!** No `CMakeLists.txt`, `Makefile`, `SConstruct`, `configure`, `automake` or `Makefile.in`. Only a `make.cpp` file will work, but a *CXX*-compatible directory structure is recommended.

The latest versions of both GCC (g++) and Clang (clang++) are always supported, and the latest released C++ standard. Create an issue if there are problems.

If you are developing a C++ **library**, *CXX* is not for you, yet. If you are looking for a simple build system for **executables**, on Linux, macOS or FreeBSD, *CXX* might be for you. *(The only way to be sure is to give it a spin)*.

`x86_64-w64-mingw32-g++` or a working installation of `docker` is required for compiling executables for 64-bit Windows. This docker image is used if the `x86_64-w64-mingw32-g++` executable is missing: `jhasse/mingw:2017-10-19`.

## Quick Start

Create a **main.cpp** file:

```c++
#include <cstdlib>
#include <iomanip>
#include <iostream>
#include <ostream>
#include <string>

using namespace std::string_literals;

class Point {
public:
    double x;
    double y;
    double z;
};

std::ostream& operator<<(std::ostream& output, const Point& p)
{
    using std::setfill;
    using std::setw;
    output << "{ "s << setfill(' ') << setw(3) << p.x << ", "s << setfill(' ') << setw(3) << p.y
           << ", "s << setfill(' ') << setw(3) << p.z << " }"s;
    return output;
}

Point operator+(const Point& a, const Point& b)
{
    return Point { .x = a.x + b.x, .y = a.y + b.y, .z = a.z + b.z };
}

Point operator*(const Point& a, const Point& b)
{
    return Point { .x = a.x * b.x, .y = a.y * b.y, .z = a.z * b.z };
}

int main(int argc, char** argv)
{
    // designated initializers
    Point p1 { .x = 1, .y = 2, .z = 3 };
    Point p2 { .y = 42 };

    using std::cout;
    using std::endl;

    cout << "     p1 = " << p1 << endl;
    cout << "     p2 = " << p2 << endl;
    cout << "p1 + p2 = " << p1 + p2 << endl;
    cout << "p1 * p2 = " << p1 * p2 << endl;

    return EXIT_SUCCESS;
}
```

Then build, run and record profiling information with:

    cxx rec

Then build again, using the recorded profiling information in the process:

    cxx

## Usage

#### Building and running

    cxx run

#### Just building

    cxx

#### Cleaning and building

    cxx rebuild

#### Building files ending with `_test.cpp`, then running them

    cxx test

#### Cleaning

    cxx clean

#### Building with `clang++` instead of `g++`:

    cxx clang

#### Debug build:

    cxx debug

#### Building a specific directory (`cxx` can take the same flags as `make`):

    cxx -C examples/hello

#### Installing on the local system, using sudo:

    sudo PREFIX=/usr cxx install

Either `main.cpp` or the C++ source files in the current directory will be used when building with `cxx`.

#### Packaging a project into `$pkgdir`:

    DESTDIR="$pkgdir" PREFIX=/usr cxx install

--- or just ---

    cxx pkg

This uses `$pkgdir="pkg"` and the name of the current directory will be used as the executable name.

#### Build a small executable:

    cxx small

#### Build an executable with optimization flags turned on:

    cxx opt

#### Strict compilation flags (complains about all things):

    cxx strict

#### Sloppy compilation flags (will ignore all warnings):

    cxx sloppy

#### Get the current version:

    cxx version

#### Format the source code:

    cxx fmt

#### Generate a qmake / QtCreator project file:

    cxx pro

#### Guided optimization

Build the executable with profiling enabled then run it and record the profiling data:

    cxx rec

Build the executable and use the profiling data, if available:

    cxx

## Features and limitations

* **No configuration files are needed**, as long as the *CXX* directory structure is followed.
* **Auto-detection** of include, define and library flags, based on which files are included from `/usr/include`, using **`pkg-config`**. It also uses system-specific ways of attempting to detect which packages provides which compilation flags. Not all libraries, include files and cxxflags can be auto-detected yet, but more are to be added.
* Built-in support for testing, clang, debug builds and only rebuilding files that needs to be rebuilt.
* Uses the caching that is supplied by SCons, no ccache is needed.
* Does not use a `build` directory, it's okay that the `main` executable ends up in the root folder of the project. `main.cpp` can be placed in the root folder of the project, or in its own directory.
* Only tested on Linux, FreeBSD and macOS. Should be easy to port to other systems that also has a package manager and pkg-config (or equivalent way to discover build flags).
* Your include files are expected to be found in `./include` or `../include`.
* Source files used by multiple executables in your project are expected to be placed in `./common` or `../common`.
* Tests are expected to end with `_test.cpp` and will be ignored when building `main.cpp`.
* See the `hello` example in the `examples` directory for the suggested directory structure.
* For now, *CXX* is only meant to be able to build executables, not libraries.
* The dependency discovery is reasonably fast, the compilation itself still takes the longest. Not to speak of the time it can take to discover build flags for some C++ libraries and features manually.

## Suggested directory structure

For a "Hello, World!" program that places the text-generation in a `string hello()` function, this is one way to structure the files, for separating the code into easily testable source files:


```
.
├── hello/main.cpp
├── hello/include/hello.h
├── hello/include/test.h
├── hello/common/hello.cpp
└── hello/common/hello_test.cpp
```

#### --- or if you prefer one directory per executable ---

```
.
└── hello/hello1/main.cpp
└── hello/hello2/main.cpp
└── hello/include/hello.h
└── hello/include/test.h
└── hello/common/hello.cpp
└── hello/common/hello_test.cpp
```

**main.cpp**

```c++
#include <iostream>
#include "hello.h"

int main()
{
    std::cout << hello() << std::endl;
    return 0;
}
```

**hello.h**

```c++
#pragma once

#include <string>

std::string hello();
```

**hello.cpp**

```c++
#include "hello.h"

using namespace std::literals;

std::string hello()
{
    return "Hello, World!"s;
}
```

**hello_test.cpp**

```c++
#include "test.h"
#include "hello.h"

using namespace std::literals;

void hello_test()
{
    equal(hello(), "Hello, World!"s);
}

int main()
{
    hello_test();
    return 0;
}
```

**test.h**

```c++
#pragma once

#include <iostream>
#include <cstdlib>

template<typename T>
void equal(T a, T b)
{
    if (a == b) {
      std::cout << "YES" << std::endl;
    } else {
      std::cerr << "NO" << std::endl;
      exit(EXIT_FAILURE);
    }
}
```

## Requirements

* `scons`
* `make`
* `g++` with support for C++2a (gcc version 8.2.1 or higher should work)
* `pkg-config`, for systems where pkg-config is available

#### Optional requirements

* `clang++` with support for C++2a (build with `cxx clang`).
* `lldb` or `gdb` for debugging
* `pkgfile` on Arch Linux, for faster dependency discovery.
* `apt-file` on Debian/Ubuntu, for faster dependency discovery.
* `x86_64-w64-mingw32-g++` or `docker`, for cross-compiling executables for 64-bit Windows. The docker service must be up and running for this to work.
* `wine`, for testing executables compiled for 64-bit Windows (`cxx run`).
* `valgrind`, for profiling (`cxx valgrind`).
* `kcachegrind`, for viewing the information produced by *valgrind*.
* `gprof2dot` and `dot`, for producing a graph from the information produced by valgrind.
* `vagrant`, for testing *cxx* on other operating systems.
* `figlet`, for nicer output when running the `tests/build_all.sh` script, for building all the examples.
* Development packages for `SDL2`, `OpenGL`, `glut`, `glfw`, `sfml`, `GTK+3` and `Qt5`, for building and running the examples.
* `x86_64-w64-mingw32-g++` or `docker` is needed for building the `win64crate` example.
* `clang-format` for `cxx fmt`.

## Defines

These defines are passed to the compiler, if the corresponding paths exist (or will exist, when packaging):

* `DATADIR` is defined as `./data` or `../data` (when developing) and `$PREFIX/share/application_name/data` (at installation time)
* `IMGDIR` is defined as `./img` or `../img` (when developing) and `$PREFIX/share/application_name/img` (at installation time)
* `SHADERDIR` is defined as `./shaders` or `../shaders` (when developing) and `$PREFIX/share/application_name/shaders` (at installation time)
* `SHAREDIR` is defined as `./share` or `../share` (when developing) and `$PREFIX/share/application_name` (at installation time)
* `RESOURCEDIR` is defined as `./resources` or `../resources` (when developing) and `$PREFIX/share/application_name/resources` (at installation time)
* `RESDIR` is defined as `./res` or `../res` (when developing) and `$PREFIX/share/application_name/res` (at installation time)

This makes it easy to have an `img`, `data` or `resources` directory where files can be found and used both at development and at installation-time.

See `examples/sdl2` and `examples/win64crate` for examples that uses `IMGDIR`.

See `examples/mixer` for an example that uses `RESOURCEDIR`.

An alternative method to using defines (defined with `-D` when building) is to use something like `SDL_GetBasePath()`. Example: [res_path.h](https://github.com/libSDL2pp/TwinklebearDev-Lessons-libSDL2pp/blob/sdl2pp/include/res_path.h).

## C++2a on macOS

For installing a recent enough version of C++ on macOS, installing gcc 8 with `brew` is one possible approach:

    brew install gcc@8

The other requirements can be installed with:

    brew install scons make pkg-config

## C++2a on Arch Linux

g++ with support for C++2a should already be installed.

Install scons and base-devel, if needed:

    pacman -S scons base-devel --needed

## C++2a on Debian or Ubuntu

You might need to install GCC 8 from the testing repository, or from a PPA.

Install build-essential, scons and pkg-config:

    apt install build-essential scons pkg-config

## C++17 on FreeBSD

FreeBSD 11.1 comes with C++17 support, but you may wish to install gcc8 or later for C++17 support.

Install pkg-conf, scons and gmake:

    pkg install pkgconf scons gmake

## Installation

Manual installation with `make` and `sudo`:

`sudo make install`

On FreeBSD, use `gmake` instead of `make`.

If possible, install *CXX* with the package manager that comes with your OS/distro.

## Uninstallation

`sudo make uninstall`

## One way of structuring projects

#### Filenames

* All include filenames should contain no spaces or special characters (a-z, A-Z, 0-9) and end with `.h` or `.hpp`.
* All C++17 source filenames should contain no spaces or special characters (a-z, A-Z, 0-9) and end with `.cpp`, `.cc` or `.cxx`.
* The main source file could be named `main.cpp` or `main.cc`, but it does not have to.
* Files ending with `_test.*` are special, and will not be used when compiling the main executable(s).

#### Directories

* `include/` should contain all include files belonging to the project.
* `common/` should contain all source code that can be shared between multiple executables.
* The top level directory, or `src/`, or a custom directory should contain at least one source file containing a `main` function.
* The name of the produced executable will be the same as the name of the parent directory, or `main` if the parent directory is `src`.
* `img/` should contain all images.
* `shaders/` should contain all shaders.
* `data/` should contain all other data files needed by the program.
* `shared/` should contain all files optionally needed by the program, like example data.

#### Testing

* All source files, except the one containing the `main` function, should have a corresponding `_test` file. For instance: `quaternions.cc` and `quaternions_test.cc`.
* When running `cxx test`, the `_test.*` files will be compiled and run.
* `*_test.*` files must each contain a `main` function.

#### Ninja

* Projects that already uses CMake (and need no extra command line arguments when running `cmake`) are also CXX compatible and can be built with CMake + Ninja like this:

    cxx ninja

#### QtCreator

The generated qmake/QtCreator project files were tested with QtCreator 4.6 on Arch Linux.

## Source code formatting

* `cxx fmt` will format C++17 source code in a single, fixed, formatting style (clang-format "Webkit"-style), which is not configurable, on purpose. Using `cxx fmt` is optional.

## Feedback

The goal is that every executable and project written in C++17 should be able to build with `cxx` on a modern Linux distro, FreeBSD or macOS system (with Homebrew), without any additional configuration.

If you have a project written in C++17 that you think should build with `cxx`, but doesn't, please create an issue and include a link to your repository.

## Editor Configuration

Syntastic settings for ViM and NeoVim:

    " C++17 by default
    let g:syntastic_cpp_compiler = 'g++'
    let g:syntastic_cpp_compiler_options = ' -std=c++17 -pipe -fPIC -fno-plt -fstack-protector-strong -Wall -Wshadow -Wpedantic -Wno-parentheses -Wfatal-errors -Wvla'
    let g:syntastic_cpp_include_dirs = ['../common', './common', '../include', './include']

    " Ignore some defines and warnings
    let g:syntastic_quiet_messages = {
        \ "!level": "errors",
        \ "regex":  [ 'RESOURCEDIR', 'RESDIR', 'DATADIR', 'IMGDIR', 'SHAREDIR', 'SHADERDIR', 'expected .*).* before string constant' ] }

## General info

* Version: 3.0.3
* License: MIT
* Author: Alexander F. Rødseth &lt;xyproto@archlinux.org&gt;
