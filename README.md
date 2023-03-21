# update-project-version

GitHub action to automatically update project version and create version tag.

## Prerequisites

[![GNU Bash](https://skillicons.dev/icons?i=bash)](https://www.gnu.org/software/bash/)
[![Git](https://skillicons.dev/icons?i=git)](https://git-scm.com/)

Current version in the project and use [semantic versioning](https://semver.org/) as well as [conventional commits](https://www.conventionalcommits.org/en/v1.0.0/).

## Usage

Add a step to your GitHub workflow using the action. For example:

```yaml
name: my-workflow

run-name: Do stuff + update version

on:
  push:
    branches:
      - '**'

jobs:
  do_stuff:
    runs-on: [self-hosted, linux]
    name: Do stuff
    steps:
      - id: echo_stuff
        name: Echo stuff
        run: echo "Doing stuff"
        shell: bash
  update_version:
    if: ${{ github.ref == 'refs/heads/develop' }}
    needs: do_stuff
    runs-on: [self-hosted, linux]
    name: Update project version
    steps:
      - id: new_version
        uses: nomasystems/update-project-version@latest
        with:
          tag-prefix: "v"
          version-files: "File1,File2,File3"
```

The action accepts the following inputs:

| Input param     | Required                 | Default value | Description                                                 |
|-----------------|--------------------------|---------------|-------------------------------------------------------------|
| `latest-tag`    | :heavy_multiplication_x: | 'false'       | Indicates if an extra tag "latest" should be added          |
| `tag-preffix`   | :heavy_multiplication_x: | ''            | Git tag prefix (tag chars before the version chars)         |
| `tag-suffix`    | :heavy_multiplication_x: | ''            | Git tag suffix (tag chars after the version chars)          |
| `version-files` | :heavy_multiplication_x: | ''            | Files to update with the new version (comma separated list) |

:warning: In order to work properly, the repository must have a "current version" given by:
- Initial tag, from which the action will obtain the current version number
- Current version number in the specified "version-files", which the action will update with the new version

:warning: In order to work properly, the project must use [conventional commits](https://www.conventionalcommits.org/en/v1.0.0/) with the following considerations:
- A commit message must have the form `{type}(#{issue_number}):{message}`
- A commit with type `fix` will result in a patch update (increment the 3rd number in the version)
- A commit with type `build`, `chore`, `ci`, `docs`, `feat`, `perf`, `refactor`, `style` or `test` will result in a minor update (increment the 2nd number in the version)
- A commit with type `xxx!` (being `xxx` any valid type) or footers `BREAKING CHANGE: xxx` or `BREAKING-CHANGE: xxx` will result in a major update (increment the 1st number in the version)

## Contributing

Pull requests are welcome. Please read the [contributing guidelines](CONTRIBUTING.md) to know more about contribution.
