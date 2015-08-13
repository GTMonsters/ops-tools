A simple tool for updating one csv with quantity values from another via sku-lookup

Setup
=====

1. install ruby

  [windows] http://rubyinstaller.org/

2. install rvm

  https://rvm.io/rvm/install

  [windows] http://blog.developwithpassion.com/2012/03/30/installing-rvm-with-cygwin-on-windows/

Usage
===

in a terminal window

```
  > cd ~/your/project/dir/containing Borla.txt and turnfourteen.csv
  > ruby update-qty.rb
```

this will update `Borla.txt` with new quantity values and leave `Borla.txt.orig` as a backup
