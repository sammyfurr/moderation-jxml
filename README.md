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

## Tests

### Prerequisites

The test harness is a perl script called ```jxml_test.pl```.  To run the script, you will need perl and the Text::Diff module, which can be installed from CPAN.  You will also need to install Valgrind.  You can find Perl, Text::Diff, and Valgrind [here](https://www.perl.org/), [here](https://metacpan.org/pod/Text::Diff), and [here](http://valgrind.org/) respectively.  It is probably easiest to install all of them using your distro's builtin package manager.

### Usage

To use the test harness, you can run ```make test``` to run all tests.  Depending on the number of tests installed this may take a while, since memory tests are included.  To only run I/O correctness tests, run ```perl jxml_test.pl```.  To run memory tests as well run ```perl jxml_test.pl```.

### Adding tests

Only a few tests are included.  To add new tests, you must add a test file, n, with the name ```t<n>``` containing the input you would like to test (don't forget the newline at the end of the file!) to the ```tests``` directory.  You must also add an expectation file with the same name containing the expected output (don't forget the newline at the end of the file!) to the ```tests/exp``` directory.  The results of your tests will be in ```tests/res```.  Results are removed every time you run ```make test```.

## Paper

My moderation paper can be found in the folder ```paper```.  The file is called ```jxml.pdf```.  I've also included the LaTeX and bibliography source files in the folder.  I've also included my lab5 JSON to XML interpreter for comparison.  It is called ```lab5b.rkt```

# Thank you!