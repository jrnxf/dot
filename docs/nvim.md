# nvim

- `vim -V9myVim.log` will run vim with a hefty logger and create a file called `myVim.log`. useful for debugging issues
  and seeing stack traces

- `:v/price/d` delete all lines in a buffer that don't have `price` in them. Also, `:g!/price/d` works too since `g!` is
  an alias to `v`
