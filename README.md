# Grab

A simple tool that allows you to grab and reuse shell libraries from git repositories.

## Features

- Loading shell libraries
- Caching / Refreshing libraries
- Multiple version support
- Aliasing

### What is a shell library?

A shell library is actually a `shell script` that contains functions that you can `source` and reuse inside your own scripts.
By convention this tool assumes that the script is called `library.sh` but you can be explicit and choose any script you'd like (see below on specifying a custom path).

### Does it require installation?

Yes, but you just need to install put the `grab` script in your path once (see Installation).


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

# Aliasing

The more scripts you grab, the more likely is to get into naming clashes. For example its likely two grabbed scripts to contain a function with the same name.
This is something that one can encounter in most modern programming languages when importing, requiring etc. One common solution is to use an alias for the imported package.
A similar technique has been added to this tool, that allows you to grab a library using a special alias, using the `as` keyword.

    source $(grab <git repository> as <alias>)

Then your code will be able to access all the functions provided by the library using the `<alias>::` prefix. Here's a real example:

    source $(grab <github.com/shellib/cli as cli)
    
In order to access the `hasflag` function you now need to use `cli::hasflag`.

### Troubleshooting

Prefixing function names with an alias has its limitations. As a global `find and replace` is used (with word boundaries) is taking place to prefix functions, there is a chance that unwanted replacements happen.
To avoid those, you can prefix the function that is causing this issue with `double underscore`. For example:

    function __release() {
        mvn release:clean
    }

Note: Using the `::` as a separator between the alias and the function is convention and not a language feature. The particular convention is influenced by [Roland Huss](https://github.com/rhuss) coding style.
