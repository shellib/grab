# Grab

A simple tool that allows you to grab and reuse shell libraries from git repositories.

### What is a shell library

A shell library is actually a `shell script` that contains functions that you can `source` and reuse inside your own scripts.
By convention this tool assumes that the script is called `library.sh` but you can be explicit and choose any script you'd like (see below).

## Features

- Loading shell libraries
- Caching / Refreshing libraries
- Multiple version support

## Usage

This tool is meant to download and store the library localy, so that it can be easily imported with the `source` command.
So the general use of the tool is:

    source $(grab <git repository>)
    
Where the git repository format is: `<host>/<organization>/<repository>/<path>@<branch>`.

This will clone the library under `$HOME/.shelllib/<organization>/<repository>/<version>` and import it to your script.
        
### Usage Example:        

For example to load the `shellib cli library` from github:

    source $(grab github.com/shellib/cli)
    
This will clone the library under `$HOME/.shelllib/shellib/cli/master` and import it to your script.

## Installation

Using curl:

    curl -s https://raw.githubusercontent.com/shellib/grab/master/install.sh | bash

or using wget:

    wget -q -O - https://raw.githubusercontent.com/shellib/grab/master/install.sh | bash
