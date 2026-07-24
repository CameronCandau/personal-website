# Bash

## Tree without tree
```
find . -print | sed -e 's;[^/]*/;|____;g;s;____|; |;g'
```
