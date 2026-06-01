import os
from pathlib import Path
from dotenv import load_dotenv


def load_config(config_dir: str | Path | None = None) -> dict:
    load_dotenv()

    config = {
        "knime": {
            "executable": os.getenv(
                "KNIME_PATH",
                "C:\\Program Files\\KNIME\\knime.exe"
            ),
            "workspace": os.getenv(
                "KNIME_WORKSPACE",
                "C:\\knime-workspace"
            ),
        },
        "powerbi_rs": {
            "base_url": os.getenv("PBIRS_BASE_URL", ""),
            "domain": os.getenv("PBIRS_DOMAIN", ""),
            "username": os.getenv("PBIRS_USERNAME", ""),
            "password": os.getenv("PBIRS_PASSWORD", ""),
            "auth": os.getenv("PBIRS_AUTH", "NTLM"),
        },
        "opendesign": {
            "daemon_url": os.getenv(
                "OPENDESIGN_DAEMON_URL",
                "http://localhost:3080"
            ),
            "api_key": os.getenv("OPENDESIGN_API_KEY"),
        },
    }

    return config
