## Maxthon package tool

This part of the repository contains a Python script to pack a directory into a
mxaddon file. I've reverse-engineered the file format from MxPacker.exe from
http://forum.maxthon.com/thread-801-1-1.html (version 1.0.7, Mar 13th, 2013).

## Usage

```
mxpack.py [input directory] [optional outputfile.mxaddon]
```

If the second argument is omitted, the output file will be the input directory
concatenated with ".mxaddon".  
For example, `mxpack.py ~/Documents/myaddon/` creates `~/Documents/myaddon.mxaddon`.
If the file already exists, it will be overwritten without prompt.
