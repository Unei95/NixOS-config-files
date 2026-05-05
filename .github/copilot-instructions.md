Repository purpose

This repository contains a personal NixOS configuration intended to be used from /etc/nixos (or symlinked there). Key files: configuration.nix (system-wide NixOS config), home.nix (home-manager user config), hosts.nix (per-host variables), and a few modular imports (graphics_tablet.nix, open_webui.nix).

Build / apply / inspect commands

- Apply system configuration (assumes repo is at /etc/nixos or use -I to point):
  sudo nixos-rebuild switch
  (alias defined in configuration.nix: nixrebuild -> sudo nixos-rebuild switch)

- Apply the home-manager user configuration (run as the target user):
  home-manager switch -f ./home.nix

- Evaluate or inspect Nix expressions without building the system (helpful when editing):
  nix eval -f . --raw system.stateVersion
  nix repl -f .

- Build a specific derivation (if needed):
  nix build -f . <attribute>

- No test or lint tasks are present in the repository (no CI/test harness configured).

High-level architecture

- Top-level split: configuration.nix defines the NixOS system profile and imports host-specific and optional modules. home.nix carries the per-user home-manager configuration.
- Hosts and per-host values are centralized in hosts.nix and imported into configuration.nix — expect values like hostName, interface, and staticIp to come from hosts.nix.
- An "unstable" channel is vendored via builtins.fetchTarball inside configuration.nix and passed into the home config; this repository mixes pinned/stable system options and a fetched unstable overlay for package choices.
- hardware-configuration.nix is referenced from /etc/nixos and is expected to exist outside this repo.
- system packages (environment.systemPackages) and home-manager packages (home.packages) are used in tandem; prefer enabling programs via the appropriate layer (system vs home) depending on whether a program needs desktop/system integration or per-user configuration.

Key conventions and repo-specific patterns

- Placement: The repo is intended to be checked out directly into /etc/nixos or have each file symlinked there (see README.md). Many commands assume that placement.
- Channel pinning: unstable is imported with a fixed sha256; when updating the upstream tarball, update the sha256 accordingly.
- State versions: system.stateVersion and home.stateVersion are explicitly pinned in configuration.nix and home.nix respectively — update them only with care and after reviewing NixOS/home-manager release notes.
- Home-manager usage: home-manager.useUserPackages and home-manager.useGlobalPkgs are enabled (see configuration.nix) — home.nix expects unstable being passed in and references unstable packages (e.g., helix, vscode.fhs).
- Aliases: configuration.nix sets helpful shell aliases (nixrebuild, nixconf) — they can be used when working on this repo.
- External dependencies: some components expect files/configs outside the repo (e.g., /etc/nixos/hardware-configuration.nix, /etc/nixos/hardware-configuration.nix, and possibly per-host secrets). Review imports before applying.
- Avoid duplicating program enablement across system and home-manager; convention in this repo is to enable low-level or system-wide services in configuration.nix and development/editor tooling in home.nix.

Other AI assistant configs

- No CLAUDE.md, AGENTS.md, CONVENTIONS.md, .cursorrules, .windsurfrules, .clinerules, or similar AI assistant rule files were found in the repo to incorporate.

What is not present (so Copilot should not assume)

- No CI, test, or lint tooling is configured here; changes to system behavior should be verified by applying the configuration in a controlled environment (VM or NixOS test) rather than relying on unit tests.

Quick checklist for an edit-to-apply cycle

- Edit configuration.nix / home.nix / hosts.nix
- Commit changes
- If checked out in /etc/nixos: sudo nixos-rebuild switch
- As the user: home-manager switch -f ./home.nix

