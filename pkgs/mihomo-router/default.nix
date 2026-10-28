{rustPlatform}:
rustPlatform.buildRustPackage {
  pname = "mihomo-router";
  version = "0.2.0";

  src = ./.;

  cargoHash = "sha256-21RG7+ogONFlMH/SJng0DSCS0hVriC8ktgg0O59JIOs=";
}
