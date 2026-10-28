{rustPlatform}:
rustPlatform.buildRustPackage {
  pname = "mihomo-router";
  version = "0.2.0";

  src = ./.;

  cargoHash = "sha256-f8QhhkOR2VwHsy6qBuTe07+cacSdYbfLas0gbzHcg8c=";
}
