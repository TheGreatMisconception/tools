

# Minetest
![Minetest Logo](https://www.seekpng.com/png/small/206-2061867_minetest-is-a-near-infinite-world-block-sandbox.png)
Minetest is an open-source voxel game engine that allows players to build and explore 3D worlds, similar to Minecraft. It features multiplayer support, modding capabilities, and a variety of gameplay modes, including survival and creative.


## CompileMT

This is a Bash script to automate the compilation process of Minetest on Debian-based systems (e.g., Debian, Ubuntu, Linux Mint, MX Linux, etc.).

> A working internet connection and superuser permissions are required!

| Arguments | Description |
|--|--|
| -S | only build minetest-server|
|-s | prints the link to this Github repository|
|-c | specify the amount of cores used for the compilation, otherwise amount of available threads/cores is used
|-h | outputs a simple help dialog

## DigilinePixelart

This script is used to project complex images onto matrix screens, which are controlled by the Digiline mod. Any image can be used as the input source. The script then generates lua code which can be processed by the Lua controller

### Requirements
#### Python
The python interpreter with at least version 3.13. Older versions  may also work, but is untested.
Furthermore the PIL module must be installed.
#### Minetest
Minetest from version 5.8.0 upwards.
The installation of the following mods is required:

 - Digiline
 - streets
 - mesecons
 - digistuff (optional)

### Usage
| Parameter | Description |
|--|--|
| `--image` | path to source image |
| `--width` | width of the matrix screen array |
| `--height` | height of the matrix screen array |
| `--threshold` | color threshold for monochrome conversion |
| `--nobase` | ignore Base 16 - Might leave a lot of black areas |
| `--color` | inverts the color |
| `--save` | saves the luac-code in current working directory |
| `--quiet` | do not output the source code in the terminal |

# License

All scripts are licensed under MIT - TheGreatMisconception 2024
See LICENSE file for more information.
