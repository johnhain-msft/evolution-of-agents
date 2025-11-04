# Example: Inference using Semantic Kernel
from semantic_kernel import Kernel
import asyncio
from setup import get_project_client, create_agent, test_agent
from semantic_kernel.connectors.mcp import MCPStdioPlugin

async def main():
    client = await get_project_client()

    kernel = Kernel()

    async with MCPStdioPlugin(
        name="Playwright",
        command="npx",
        args=["@playwright/mcp@latest"],
        description="MCP Stdio Plugin for Playwright",
        version="1.0.0",
    ) as playwright_mpc:
        kernel.add_plugin(playwright_mpc, plugin_name="playwright")

        agent = await create_agent(
            agent_name="CalculatorAgentWithMcp",
            agent_instructions="You are a helpful assistant. Use tools to solve user queries.",
            client=client,
            kernel=kernel,
            plugins=[playwright_mpc],
        )

        thread = None
        user_input = "go to https://reindeerromp5k.com/ and check dates, prices and details for the race"
        thread = await test_agent(client, agent, user_input, thread)

asyncio.run(
    main()
)