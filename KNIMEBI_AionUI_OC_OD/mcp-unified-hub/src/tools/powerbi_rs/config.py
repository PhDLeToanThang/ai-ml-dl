from src.models.powerbi_rs import PBIRSConfig


def build_pbirs_config(raw: dict) -> PBIRSConfig | None:
    base_url = raw.get("base_url", "")
    if not base_url:
        return None

    return PBIRSConfig(
        base_url=base_url,
        domain=raw.get("domain", ""),
        username=raw.get("username", ""),
        password=raw.get("password", ""),
        auth=raw.get("auth", "NTLM"),
    )
