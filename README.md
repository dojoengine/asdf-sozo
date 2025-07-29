<div align="center">

# asdf-sozo [![Build](https://github.com/dojoengine/asdf-sozo/actions/workflows/build.yml/badge.svg)](https://github.com/dojoengine/asdf-sozo/actions/workflows/build.yml) [![Lint](https://github.com/dojoengine/asdf-sozo/actions/workflows/lint.yml/badge.svg)](https://github.com/dojoengine/asdf-sozo/actions/workflows/lint.yml)

[sozo](https://book.dojoengine.org/toolchain/sozo) plugin for the [asdf version manager](https://asdf-vm.com).

</div>

# Contents

- [Dependencies](#dependencies)
- [Install](#install)
- [Contributing](#contributing)
- [License](#license)

# Dependencies

- `bash`, `curl`, `tar`, `unzip` and [POSIX utilities](https://pubs.opengroup.org/onlinepubs/9699919799/idx/utilities.html).

# Install

Plugin:

```shell
asdf plugin add sozo
# or
asdf plugin add sozo https://github.com/dojoengine/asdf-sozo.git
```

sozo:

```shell
# Show all installable versions
asdf list all sozo

# Install specific version
asdf install sozo latest

# Set a version globally (on your ~/.tool-versions file)
asdf global sozo latest

# Now sozo commands are available
sozo --version
```

Check [asdf](https://github.com/asdf-vm/asdf) readme for more instructions on how to
install & manage versions.

# Contributing

Contributions of any kind welcome! See the [contributing guide](contributing.md).

[Thanks goes to these contributors](https://github.com/dojoengine/asdf-sozo/graphs/contributors)!

# License

See [LICENSE](LICENSE) © [dojoengine](https://github.com/dojoengine/)
