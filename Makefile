CC = gcc
CFLAGS = -g -Wall -I.
BUILD = build/

JSON_XML_PARSE_H = $(BUILD)json_xml.tab.h
JSON_XML_PARSE_C = $(BUILD)json_xml.tab.c
JSON_XML_PARSE = $(JSON_XML_PARSE_H) $(JSON_XML_PARSE_C)

JSON_XML_LEX = $(BUILD)json_xml.yy.c

JSON_XML = $(BUILD)jxml

all: jxml

$(JSON_XML_PARSE): json_xml.y
	bison -d -o $(JSON_XML_PARSE_C) json_xml.y

$(JSON_XML_LEX): json_xml.l $(JSON_XML_PARSE_H)
	flex -o $(JSON_XML_LEX) json_xml.l

jxml: $(JSON_XML_LEX) $(JSON_XML_PARSE)
	$(CC) $(CFLAGS) -o $(JSON_XML) json_xml.c $(JSON_XML_PARSE_C) $(JSON_XML_LEX) -lfl

clean:
	$(RM) $(BUILD)*
