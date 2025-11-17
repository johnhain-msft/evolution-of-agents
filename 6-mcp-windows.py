"""
Evolution of agents - MCP (Windows-compatible script)

MCP (Model Context Protocol) is an open spec that standardizes how AI clients
(agents, IDEs, chat apps) discover and call external tools and access resources.
It uses a client-server model where servers expose capabilities (tools/functions,
prompts, resources like files/DBs) over JSON-RPC transports (e.g., stdio, WebSocket).

This script demonstrates how agents can interact with external MCP servers using
Playwright to browse websites and extract information.
"""

import asyncio
import os
from dotenv import load_dotenv

# Load .env file explicitly before importing setup
# Using utf-8-sig encoding to handle potential BOM issues on Windows
print("Loading environment variables...")
load_dotenv(override=True, encoding='utf-8-sig')

# Verify critical environment variables are loaded
required_vars = ['AZURE_OPENAI_CHAT_DEPLOYMENT_NAME', 'AZURE_AI_FOUNDRY_CONNECTION_STRING']
missing = [var for var in required_vars if not os.getenv(var)]
if missing:
    print(f"ERROR: Missing required environment variables: {missing}")
    print("Please ensure your .env file contains these values.")
    exit(1)

from semantic_kernel import Kernel
from setup import get_project_client, create_agent, test_agent
from semantic_kernel.connectors.mcp import MCPStdioPlugin


async def main():
    """Main async function to run the MCP agent example."""

    print("Starting MCP Agent with Playwright...")
    print("-" * 60)

    # Get Azure AI Project client
    client = await get_project_client()

    # Create Semantic Kernel instance
    kernel = Kernel()

    # Use async context manager for MCP plugin
    async with MCPStdioPlugin(
        name="Playwright",
        command="npx",
        args=["@playwright/mcp@latest"],
        description="MCP Stdio Plugin for Playwright",
        version="1.0.0",
        env=os.environ.copy(),  # Pass all environment variables
    ) as playwright_mcp:
        # Add the plugin to kernel
        kernel.add_plugin(playwright_mcp, plugin_name="playwright")

        # Create agent with MCP plugin
        agent = await create_agent(
            agent_name="PlaywrightAgentWithMcp",
            agent_instructions="You are a helpful assistant. Use tools to solve user queries.",
            client=client,
            kernel=kernel,
            plugins=[playwright_mcp],
        )

        print(f"Agent created: {agent.name}")
        print("-" * 60)

        # Test the agent with a user query
        thread = None
        user_input = "go to https://reindeerromp5k.com/ and check dates, prices and details for the race"

        print(f"\nUser Query: {user_input}\n")
        print("-" * 60)

        thread = await test_agent(client, agent, user_input, thread)

        print("-" * 60)
        print("MCP Agent execution completed!")


if __name__ == "__main__":
    # Windows-specific event loop policy for proper subprocess handling
    # if asyncio.get_event_loop_policy().__class__.__name__ == 'WindowsProactorEventLoopPolicy':
    #     # Use WindowsSelectorEventLoopPolicy for better subprocess support
    #     asyncio.set_event_loop_policy(asyncio.WindowsSelectorEventLoopPolicy())

    # Run the async main function
    asyncio.run(main())
