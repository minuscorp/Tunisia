# Tunisia
![Build Status](https://github.com/minuscorp/Tunisia/workflows/Swift/badge.svg)
![GitHub release (latest by date)](https://img.shields.io/github/v/release/minuscorp/Tunisia)
![License](https://img.shields.io/static/v1?label=License&message=Apache&color=blue)
![Swift version](https://img.shields.io/badge/Swift-5.0-orange)
![Twitter Follow](https://img.shields.io/twitter/follow/minuscorp?style=social)

A Carthage local cache based on compiler, library and Xcode version.

## What does Tunisia?

Tunisia chaches your Carthage dependencies into a local cache using a number of common parameters that allows to have several Xcode, Swift or library versions installed and restored on demand with just **one compilation** per combination.

This means:

1. ✅ No more build all dependencies with several Xcode version installed.
2. ✅ No more recompiling over and over the same library when using different versions.
3. ✅ Shared cache for all your projects! If a project already cached some dependency, it can be restored from a different one if a match is done.

## Usage

### Cache

To generate your cache with Tunisia make sure you make usage of its parameters:

```
USAGE: tunisia cache [--force] [--destination-directory <destination-directory>] [--working-directory <working-directory>] <carthage-verb> [<carthage-command> ...]

ARGUMENTS:
  <carthage-verb>         The carthage verb to apply to Tunisia
  <carthage-command>      The carthage arguments to apply to Tunisia.

OPTIONS:
  --force
  -d, --destination-directory <destination-directory>
                          The destination directory of the cache (default: file:///Users/minuscorp/Library/Caches/)
  -w, --working-directory <working-directory>
                          The working directory from where to find the Cartfile (default:
                          /Users/minuscorp/Documents/GitHub/Tunisia)
  --version               Show the version.
  -h, --help              Show help information.
```

For example, if we're using the following carthage command to cache all of our depenedencies:
```
carthage bootstrap --no-use-binaries --platform iOS
```
With Tunisia you would:
```
tunisia bootstrap --no-use-binaries --platform iOS
```

That's it. You just exchange `carthage` for `tunisia`.

You have several flags that you can prepend to the carthage verb (bootstrap, build) to configure Tunisia.

### Restore

To restore a cache for your Cartfile, you can make use of Tunisia in his `restore` command:

```
USAGE: tunisia restore [--cache-directory <cache-directory>] [--working-directory <working-directory>] [<dependencies-to-restore> ...]

ARGUMENTS:
  <dependencies-to-restore>
                          The carthage dependencies to restore, defaults to all.

OPTIONS:
  -c, --cache-directory <cache-directory>
                          The directory of the cache (default: file:///Users/minuscorp/Library/Caches/)
  -w, --working-directory <working-directory>
                          The working directory from where to find the Cartfile (default:
                          /Users/minuscorp/Documents/GitHub/Tunisia)
  --version               Show the version.
  -h, --help              Show help information.
```

The usage of restore is even easier:

```
tunisia restore
```

And the tool makes all the heavy lifting under the hood.

## Installation

### Download Binary

```
$ curl -Ls https://github.com/minuscorp/Tunisia/releases/download/latest/tunisia.macos.zip -o /tmp/tunisia.macos.zip
$ unzip -j -d /usr/local/bin /tmp/tunisia.macos.zip 
```

### From Sources
Requirements:

Swift 5.0 runtime and Xcode installed in your computer.

### Using Homebrew

`brew tap minuscorp/tunisia`

`brew install tunisia`

### Building with Swift Package Manager

```
$ git clone https://github.com/minuscorp/Tunisia.git
$ cd Tunisia
$ make install
```

## Contact

Follow and contact me on Twitter at [@minuscorp](https://twitter.com/minuscorp).

## Contributions

If you find an issue, just [open a ticket](https://github.com/minuscorp/Tunisia/issues/new) on it. Pull requests are warmly welcome as well.

## License

ModuleInterface is licensed under the Apache 2.0. See [LICENSE](https://github.com/minuscorp/Tunisia/blob/master/LICENSE) for more info.
