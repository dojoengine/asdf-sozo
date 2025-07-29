<div align="center">

# asdf-katana [![Build](https://github.com/dojoengine/asdf-katana/actions/workflows/build.yml/badge.svg)](https://github.com/dojoengine/asdf-katana/actions/workflows/build.yml) [![Lint](https://github.com/dojoengine/asdf-katana/actions/workflows/lint.yml/badge.svg)](https://github.com/dojoengine/asdf-katana/actions/workflows/lint.yml)

[katana](https://book.dojoengine.org/toolchain/katana) plugin for the [asdf version manager](https://asdf-vm.com).

</div>

# Contents

- [Dependencies](#dependencies)
- [Install](#install)
- [Contributing](#contributing)
- [License](#license)

# Dependencies

- `bash`, `curl`, `tar`, `unzip` and [POSIX utilities](https://pubs.opengroup.org/onlinepubs/9699919799/idx/utilities.html).
- Optional: Set `ASDF_NATIVE_BUILD=true` environment variable to download native builds (optimized for your specific platform).

# Install

Plugin:

```shell
asdf plugin add katana
# or
asdf plugin add katana https://github.com/dojoengine/asdf-katana.git
```

katana:

```shell
# Show all installable versions
asdf list all katana

# Install specific version
asdf install katana latest

# Set a version globally (on your ~/.tool-versions file)
asdf global katana latest

# Now katana commands are available
katana --version
```

Check [asdf](https://github.com/asdf-vm/asdf) readme for more instructions on how to
install & manage versions.

# Contributing

Contributions of any kind welcome! See the [contributing guide](contributing.md).

[Thanks goes to these contributors](https://github.com/dojoengine/asdf-katana/graphs/contributors)!

# License

See [LICENSE](LICENSE) © [dojoengine](https://github.com/dojoengine/)
