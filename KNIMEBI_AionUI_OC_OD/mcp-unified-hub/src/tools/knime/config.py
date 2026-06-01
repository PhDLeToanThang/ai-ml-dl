from src.models.knime import KNIMEConfig


def build_knime_config(raw: dict) -> KNIMEConfig:
    return KNIMEConfig(
        executable=raw.get("executable", "C:\\Program Files\\KNIME\\knime.exe"),
        workspace=raw.get("workspace", "C:\\knime-workspace"),
    )
