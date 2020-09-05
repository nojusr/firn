![firn logo](https://kelp.ml/u/axdx.png)
# firn
The chillest IRC library.

# NOTICE
This library is still in moderate development, things are very likely to change in the future.


## What is firn?
Firn is modern IRC v3 library written in pure dart. Used in Igloo IRC for android.

## How does it work?
Firn relies on an object-based event stream. Any important messages coming from a server
are parsed and sent through this event stream. This stream can have any number of listeners.

## Examples
Examples can be found in `/examples`.
* `basic.dart` shows off Firn in a single-server enviroment
* `pool.dart` shows how Firn can be used in multiple servers at the same time

