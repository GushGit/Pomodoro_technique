Pomodoro technique oriented utility

## For common users

This program is a pomodoro technique oriented utility. Pomodoro technique is used to increase productivity. It uses a mix of work and break periods to do so.

This utility, besides potentially increasing your productivity allows you to:
1. Configure templates for different work modes:
    - Set time for your work and break periods.
    - Select the playlist and set the volume to a comfortable level.
2. Create and listen to playlist of your own choice. As for now, the playlist configuration is manual and requires downloading the `.mp3` files for each entry.

Before starting, it's better to check, whether or not you have `kdialog` package.
If you're on debian-based distro:
`apt install kdialog`
If you're on arch-based distro:
`pacman -S kdialog`

If you encounter a bug or have some ideas on expanding this project, please let me know via GitHub:
> https://github.com/GushGit

## For programmers

This is an open-source college project, 100% shell scripted. Any changes and fresh ideas in forks of this project are welcome and are encouraged.

Project requires multiple packages to be installed such as:
- `kdialog`
- `sox`'s `play` package
And, also, here are some commands that might already be built-in, but are listed here just in case:
- `sed`     (text formatter)
- `grep`    (text analyzer)
- `echo`    (text output)
- `ps`      (processes manager)
- `sleep`   (thread management)
- many others, which I don't care enough to list

There are flags, that can be used when starting program from terminal:
> `-d`: enables "debug-mode", which turns every minute of waiting into a second. Very useful for testing, while customising source code.
> `-f`: enables "fast-customizing-mode", which turns off the error messages shown, when input is an empty string. Instead of forcing user to enter correct value it will just substitute parameter with its default value. List of default values:
- full=120 (here and further time is in minutes)
- work=30
- short_break=5
- long_break=10