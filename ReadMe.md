# EmperorC 

## Introduction

EmperorC is a toolkit (including library, GUI frond-end, and command-line tool) for parsing and analyzing C source code written in Lua scripting language.

The library is `emperor_c.lua`, it depends two Lua libraries which are contained in the `3rd` directory:

- [lpeg](http://www.inf.puc-rio.br/~roberto/lpeg/),  a pattern matching library for Lua
- [dkjson](https://github.com/LuaDist/dkjson) ,a lua json decoder/encoder.

The GUI front-end is named `qinhuang`, and the command-line script is called `hanwu`, they are famous emperors in China's history.

## Run from source

Run GUI front-end 

```shell
love tools/qinhuang
```

Run command-line script

```shell
./tools/hanwu <arguments>
```

## Test 

The source code comes with some built-in cases, it can be tested with [busted](https://olivinelabs.com/busted/). The following command will invoke busted to start testing.

```shell
make test
```

## Build

### GUI frond-end

GUI front-end is based on [love2d](https://love2d.org/), run following command will create a love archive called `qinhuang.love` in the current directory.

```shell
make qinhuang
```

You can run it directly by love executable of your system.

If you want to make it run indepently, i.e. make the .love archive to a distributable executable, just see [Game Distribution of Love2d wiki](https://love2d.org/wiki/Game_Distribution).

### Command line tool

Install related lua dependencies and copy tools/hanwu to your `$PATH`.

## Documentation

Working in process ...