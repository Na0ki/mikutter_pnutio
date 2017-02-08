# mikutter_pnutio

mikutter plugin for pnut.io

## features

- home timeline
- public timeline
- bookmark post

### TODO

- repost
- create new post

## how to install this plugin

requirements: `git` command

```
$ mkdir -p ~/.mikutter/plugin
$ cd ~/.mikutter/plugin
$ git clone https://github.com/Petitsurume/mikutter_pnutio
```

please mikutter restart.

## how to install mikutter?

if you using linux distro, please first try install from package manager.

### install from package manager

#### debian/ubuntu (apt)

```
sudo apt-get update
sudo apt-get install mikutter
```

#### ArchLinux (with yaourt)

```
yaourt -S mikutter
```

**NOTE: this plugin required mikutter version is >= 3.5.0. please check mikutter version(try run `mikutter -v`).
if installed mikutter version < 3.5.0, please manual install.**

### manual install

requirements: `ruby` (version >= 2.3), `bundle` command, `git`

```
cd /path/to/any/dir/
git clone https://github.com/mikutter/mikutter
cd mikutter
bundle install
```

please run `ruby mikutter.rb`
