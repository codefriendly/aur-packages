# Codefriendly AUR packages

Monorepo for Arch User Repository packages maintained by Codefriendly.
Each top-level package directory is a Git subtree whose history can be split and
pushed to its corresponding AUR `pkgbase` repository.

## Packages

- [`feather-wallet`](https://aur.archlinux.org/packages/feather-wallet)
- [`sononym`](https://aur.archlinux.org/packages/sononym)

## Adopting another package

Import an existing package directly from its public AUR Git repository:

```bash
_scripts/adopt --dry-run pkgbase
_scripts/adopt pkgbase
```

Adoption clones `https://aur.archlinux.org/<pkgbase>.git`, validates its basic
metadata, and imports its complete history under the matching top-level
directory using `git subtree`. The operation creates a subtree commit, so it
requires an existing commit and a clean worktree.

This repository uses “adopt” to mean importing package history. It does not
claim the package or grant maintainership on the AUR website.

### Importing an existing local repository

When a package already has a local standalone repository, import that repository
directly instead of cloning it again:

```bash
git subtree add --prefix=pkgbase /path/to/local-package-repository master
```

The monorepo must already have an initial commit, its worktree must be clean,
and the target prefix must not exist. Do not use `--squash`; retaining the full
history allows subsequent subtree splits to fast-forward the AUR repository.

After importing, verify the history relationship:

```bash
split=$(git subtree split --prefix=pkgbase)
git fetch https://aur.archlinux.org/pkgbase.git master:refs/remotes/aur/pkgbase
git merge-base --is-ancestor refs/remotes/aur/pkgbase "$split"
```

## Publishing

Requirements:

- Git with `git subtree`
- an SSH key registered with the AUR
- `makepkg`, used to require an exactly current `.SRCINFO`

Preview a publication:

```bash
_scripts/publish --dry-run feather-wallet
```

Publish it:

```bash
_scripts/publish feather-wallet
```

The script verifies a clean worktree, requires committed subtree history,
checks `.SRCINFO` against `makepkg --printsrcinfo`, extracts only the selected
package's history, confirms the update is a fast-forward from the current AUR
branch, and pushes it over SSH. It never force-pushes.

Dry-run previews the Git ref update without sending it. It does not transfer
objects or execute AUR receive hooks, so only a real push can confirm that
server-side validation accepts the package.

The AUR still stores one Git repository per `pkgbase`; this repository is the
single development and archival source for all of them.
