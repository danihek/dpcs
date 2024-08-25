<h1 align="center">DPCS</h1>
<p align="center"> Dependency Check Search</p>

##
<p align="center">
<img src="./assests/dpcs.gif" alt="Preview" width="500px">
</p>

# Why
I started using wlroots for my wayland compositor so I wanted to have quicker access to source code of libraries to know what am I even doing.

# Languages Support
Currently it's working only for C libraries with pkg-config.

## Dependecies:
- fzf
- bat
- ripgrep
- pkg-config
- git (optional)
- some text editor, works best with **vim** and **nvim**

## Usage:

Run ``dpcs`` in your project directory and add your dependecies to a file!
Now you can browse really fast source code of libraries with **ripgrep** & **fzf** & **bat**!

## How does this work?

Script creates hash of initial git commit or path of current folder, and stores dependencies in ``~/.cache/dpcs/$HASH``
that can be accessed later.
