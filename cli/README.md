# mkchart

<div align="center">
A general purpose project template for golang CLI applications
<br>
<br>
This template serves as a starting point for golang commandline applications it is based on golang projects that I consider high quality and various other useful blog posts that helped me understanding golang better.
<br>
<br>
<img src="https://github.com/kriipke/umbrella-chart/cli/actions/workflows/test.yml/badge.svg" alt="drawing"/>
<img src="https://github.com/kriipke/umbrella-chart/cli/actions/workflows/lint.yml/badge.svg" alt="drawing"/>
<img src="https://pkg.go.dev/badge/github.com/kriipke/umbrella-chart/cli.svg" alt="drawing"/>
<img src="https://codecov.io/gh/kriipke/umbrella-chart/cli/branch/main/graph/badge.svg" alt="drawing"/>
<img src="https://img.shields.io/github/v/release/kriipke/umbrella-chart/cli" alt="drawing"/>
<img src="https://img.shields.io/docker/pulls/kriipke/umbrella-chart/cli" alt="drawing"/>
<img src="https://img.shields.io/github/downloads/kriipke/umbrella-chart/cli/total.svg" alt="drawing"/>
</div>

# Table of Contents
<!--ts-->
   * [mkchart](#mkchart)
   * [Features](#features)
   * [Project Layout](#project-layout)
   * [How to use this template](#how-to-use-this-template)
   * [Demo Application](#demo-application)
   * [Makefile Targets](#makefile-targets)
   * [Contribute](#contribute)

<!-- Added by: morelly_t1, at: Tue 10 Aug 2021 08:54:24 AM CEST -->

<!--te-->

# Features
- [goreleaser](https://goreleaser.com/) with `deb.` and `.rpm` packer and container (`docker.hub` and `ghcr.io`) releasing including `manpages` and `shell completions` and grouped Changelog generation.
- [golangci-lint](https://golangci-lint.run/) for linting and formatting
- [Github Actions](.github/worflows) Stages (Lint, Test (`windows`, `linux`, `mac-os`), Build, Release) 
- [Gitlab CI](.gitlab-ci.yml) Configuration (Lint, Test, Build, Release)
- [cobra](https://cobra.dev/) example setup including tests
- [Makefile](Makefile) - with various useful targets and documentation (see Makefile Targets)
- [Github Pages](_config.yml) using [jekyll-theme-minimal](https://github.com/pages-themes/minimal) (checkout [https://kriipke.github.io/mkchart/](https://kriipke.github.io/mkchart/))
- Useful `README.md` badges
- [pre-commit-hooks](https://pre-commit.com/) for formatting and validating code before committing

# Project Layout
* [assets/](https://pkg.go.dev/github.com/kriipke/umbrella-chart/cli/assets) => docs, images, etc
* [cmd/](https://pkg.go.dev/github.com/kriipke/umbrella-chart/cli/cmd)  => commandline configurartions (flags, subcommands)
* [pkg/](https://pkg.go.dev/github.com/kriipke/umbrella-chart/cli/pkg)  => packages that are okay to import for other projects
* [internal/](https://pkg.go.dev/github.com/kriipke/umbrella-chart/cli/pkg)  => packages that are only for project internal purposes
- [`tools/`](tools/) => for automatically shipping all required dependencies when running `go get` (or `make bootstrap`) such as `golang-ci-lint` (see: https://github.com/golang/go/wiki/Modules#how-can-i-track-tool-dependencies-for-a-module)
)
- [`scripts/`](scripts/) => build scripts 

# How to use this template
```sh
bash <(curl -s https://raw.githubusercontent.com/kriipke/umbrella-chart/cli/master/install.sh)
```

In order to make the CI work you will need to have the following Secrets in your repository defined:

Repository  -> Settings -> Secrets & variables -> `CODECOV_TOKEN`, `DOCKERHUB_TOKEN` & `DOCKERHUB_USERNAME`

# Demo Application

```sh
$> mkchart -h
golang-cli project template demo application

Usage:
  mkchart [flags]
  mkchart [command]

Available Commands:
  completion  Generate the autocompletion script for the specified shell
  example     example subcommand which adds or multiplies two given integers
  help        Help about any command
  version     mkchart version

Flags:
  -h, --help   help for mkchart

Use "mkchart [command] --help" for more information about a command.
```

```sh
$> mkchart example 2 5 --add
7

$> mkchart example 2 5 --multiply
10
```

# Makefile Targets
```sh
$> make
bootstrap                      install build deps
build                          build golang binary
clean                          clean up environment
cover                          display test coverage
docker-build                   dockerize golang application
fmt                            format go files
help                           list makefile targets
install                        install golang binary
lint                           lint go files
pre-commit                     run pre-commit hooks
run                            run the app
test                           display test coverage
```

# Contribute
If you find issues in that setup or have some nice features / improvements, I would welcome an issue or a PR :)
