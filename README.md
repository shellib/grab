# Shell Lib

A simple tool that allows you to reuse shell libraries from git repositories.

## Features

- Loading shell libraries
- Caching / Refreshing libraries
- Multiple version support

## Usage

This tool is meant to download and store the library localy, so that it can be easily imported with the `source` command.
So the general use of the tool is:

    source $(shellib <git repository>)
    
Where the git repository format is: `<host>/<organization>/<repository>/<path>@<branch>`.

This will clone the library under `$HOME/.shelllib/<organization>/<repository</<version>` and import it to your script.
        
### Usage Example:        

For example to load the `shellib cli library` from github:

    source $(shellib github.com/shellib/cli)
    
This will clone the library under `$HOME/.shelllib/shellib/cli</master` and import it to your script.
