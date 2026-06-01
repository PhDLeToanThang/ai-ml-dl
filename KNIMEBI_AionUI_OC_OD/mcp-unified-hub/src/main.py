import sys
import argparse

from mcp.server.fastmcp import FastMCP

from src.tools.knime import register_knime_tools
from src.tools.powerbi_rs import register_powerbirs_tools
from src.tools.opendesign import register_opendesign_tools
from src.utils.config import load_config
from src.utils.logging import setup_logging

logger = setup_logging()

mcp = FastMCP(
    name="aionui-integration-hub",
    instructions=(
        "Unified Integration Hub for:\n"
        "- KNIME Analytics Platform (knime_* tools)\n"
        "- Power BI Report Server on-premises (powerbirs_* tools)\n"
        "- Open Design by nexu-io (opendesign_* tools)\n\n"
        "KNIME: execute workflows headless, read output tables.\n"
        "PBIRS: manage reports, folders, datasources, trigger refresh.\n"
        "Open Design: generate prototypes/decks, apply design systems."
    ),
    version="1.0.0",
)


def main():
    parser = argparse.ArgumentParser(description="MCP Unified Integration Hub")
    parser.add_argument(
        "--transport",
        choices=["stdio", "http"],
        default="stdio",
        help="Transport protocol (default: stdio)",
    )
    parser.add_argument(
        "--port",
        type=int,
        default=8081,
        help="HTTP port (default: 8081, used only with --transport http)",
    )
    parser.add_argument(
        "--log-level",
        choices=["DEBUG", "INFO", "WARNING", "ERROR"],
        default="INFO",
        help="Logging level (default: INFO)",
    )

    args = parser.parse_args()
    setup_logging(args.log_level)

    config = load_config()

    register_knime_tools(mcp, config)
    register_powerbirs_tools(mcp, config)
    register_opendesign_tools(mcp, config)

    logger.info(
        "Starting MCP hub: transport=%s, port=%s",
        args.transport,
        args.port if args.transport == "http" else "N/A"
    )

    if args.transport == "http":
        mcp.run(transport="http", port=args.port)
    else:
        mcp.run(transport="stdio")


if __name__ == "__main__":
    main()
