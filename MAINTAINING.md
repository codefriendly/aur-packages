# Maintaining the package monorepo

## Repository model

The AUR stores one Git repository per `pkgbase`. This monorepo keeps each
package in a top-level directory and connects its standalone history to the
main repository with `git subtree`.

The directories are ordinary tracked files, not nested repositories or Git
submodules. Subtree import commits connect the original package history to the
monorepo; `git subtree split` reconstructs a package-only history for
publication.

## Requirements

- Git with `git subtree`
- `makepkg`
- an SSH key registered with the AUR for publication
- AUR maintainership or co-maintainership for packages being published

## Adopting a package from the AUR

Import an existing package directly from its public AUR Git repository:

```bash
_scripts/adopt --dry-run pkgbase
_scripts/adopt pkgbase
```

The script clones `https://aur.archlinux.org/<pkgbase>.git`, validates its basic
metadata, imports its complete history under the matching top-level directory,
and verifies that the imported AUR tip remains in the split history.

The operation creates a subtree commit, so it requires an existing commit, a
clean worktree, and an unused target directory.

Here, “adopt” means importing package history. It does not claim the package or
grant maintainership on the AUR website.

## Importing an existing local repository

When a package already has a local standalone repository, import it directly:

```bash
git subtree add \
  --prefix=pkgbase \
  /path/to/local-package-repository \
  master
```

Do not use `--squash`; retaining the complete history allows subsequent splits
to remain fast-forward updates of the AUR repository.

Verify the relationship after importing:

```bash
split=$(git subtree split --prefix=pkgbase)
git fetch \
  https://aur.archlinux.org/pkgbase.git \
  master:refs/remotes/aur/pkgbase
git merge-base --is-ancestor refs/remotes/aur/pkgbase "$split"
```

A zero exit status from `git merge-base --is-ancestor` confirms the relationship.

## Pulling updates from another package repository

If a standalone package repository gains commits after its initial import, pull
them into the existing subtree:

```bash
git subtree pull \
  --prefix=pkgbase \
  /path/to/local-package-repository \
  master
```

This was used to import the later Feather Wallet Trezor compatibility patch
without rewriting package history.

## Updating a package

Make changes inside only the relevant package directory, then regenerate
`.SRCINFO`:

```bash
cd pkgbase
makepkg --printsrcinfo > .SRCINFO
cd ..
```

Review the package files and commit them in the monorepo. A commit touching
multiple package directories is split into each affected package history, so
package-specific commits are preferred.

## Publishing

Preview the Git ref update:

```bash
_scripts/publish --dry-run pkgbase
```

Publish over SSH:

```bash
_scripts/publish pkgbase
```

The publishing script:

1. requires a clean worktree and committed package history;
2. requires `.SRCINFO` to exactly match `makepkg --printsrcinfo`;
3. fetches the current public AUR history;
4. splits only the selected package directory;
5. rejects a non-fast-forward update; and
6. pushes without `--force`.

Dry-run does not send objects or execute AUR receive hooks. Only a real push can
confirm SSH authorization and server-side validation.

## Licensing

Repository tooling and documentation written by CodeFriendly are MIT-licensed.
Imported package histories and third-party material retain their own terms. See
[LICENSE](LICENSE) and [NOTICE.md](NOTICE.md).
