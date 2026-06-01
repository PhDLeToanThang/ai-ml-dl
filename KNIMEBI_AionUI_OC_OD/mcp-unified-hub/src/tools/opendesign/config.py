from src.models.opendesign import OpenDesignConfig


def build_opendesign_config(raw: dict) -> OpenDesignConfig:
    return OpenDesignConfig(
        daemon_url=raw.get("daemon_url", "http://localhost:3080"),
        api_key=raw.get("api_key"),
    )
