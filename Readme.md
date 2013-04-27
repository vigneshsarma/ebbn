#Emacs, Better Buffer Names
===
Emacs buffer names are difficult to search by and select especially when there are multiple files with the same name.
When there are multiple files with the same name they are shown are numbered from 2, 3.. like `file.ext`, `file.ext<2>` etc 
This is difficult to read and chose which is the file you want.
Of-course you could rename the buffer yourself, but that you have to do it your self each time.
A good alternative would be to add the parent folder as a part of the buffer name by default.
Doing it in a configurable way is the aim of this package.

## To-do:
* Provide a hook to `file-open`.
* Provide reg-ex based short names for file paths.
* Package it for package.el and upload it to melpa
* Iterate.