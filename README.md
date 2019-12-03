# Sammy Furr - Moderation Project

My moderation project consists of a json to xml interpreter called jxml written using Flex and Bison, as well as a paper with analysis.

## Installation of jxml

### Prerequisites

Flex and Bison are required to build jxml.  It is probably easiest to install them using your distro's builtin package manager.  Flex's source code is [here](https://github.com/westes/flex), and Bison's is [here](https://www.gnu.org/software/bison/).

### Installation

After Flex and Bison are installed, building is easy:

```bash
make
```

will create the executable ```jxml``` in the ```build``` directory, along with the lexer and parser files ```json_xml.yy.c```, ```json_xml.tab.c```, and ```json_xml.tab.h```.

## Usage

To run, simply type:

```bash
./jxml
```
This will give you a REPL to put JSON in.  For example:
```bash
./
{"Person" : { "Last Name" : "Furr", "First Name" : "Samuel"}}
<Person><Last Name>Furr</Last Name><First Name>Samuel</First Name></Person>
```
## Paper

My moderation paper can be found in the folder ```paper```.  The file is called ```jxml.pdf```.  I've also included the LaTeX and bibliography source files in the folder.  I've also included my lab5 JSON to XML interpreter for comparison.  It is called ```lab5b.rkt```

# Thank you!