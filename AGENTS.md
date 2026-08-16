# Repository guidance

This repository contains multiple Arch User Repository packages, each in its
own top-level directory. Keep package changes scoped to the relevant package.

## Updating a package

1. Check the upstream project's official release page, repository, or package
   metadata for a newer version. Compare the current `pkgver`, source URLs,
   and checksums before making changes.
2. Do initial update work in an isolated temporary directory under `/tmp`.
   Copy the complete package directory, including patches, helper scripts, and
   `.SRCINFO`, so failed updates do not dirty the repository.
3. Update `PKGBUILD`, regenerate `.SRCINFO` with
   `makepkg --printsrcinfo > .SRCINFO`, and run a real test build before
   finalizing the update:

   ```bash
   makepkg --cleanbuild --clean --noconfirm
   ```

   Use `--nodeps` only when dependency installation is unnecessary or
   unavailable, and report that limitation. For architecture-specific
   packages, test the native architecture and validate the other architecture's
   source URL and checksum metadata.
4. Review the resulting diff, then apply only the intended changes to the
   repository package directory. Regenerate `.SRCINFO` there as well.
5. Before reporting completion, run `git diff --check`, verify that `.SRCINFO`
   matches `makepkg --printsrcinfo`, and confirm that only intended files are
   modified.

Do not commit or publish package changes unless explicitly requested. Follow
[`MAINTAINING.md`](MAINTAINING.md) for subtree history, adoption, and AUR
publishing procedures.
