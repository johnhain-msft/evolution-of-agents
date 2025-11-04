# Example: Inference using Semantic Kernel
from semantic_kernel import Kernel
import asyncio
from setup import get_project_client, create_agent, test_agent
from semantic_kernel.connectors.mcp import MCPStreamableHttpPlugin

async def main():
    client = await get_project_client()

    kernel = Kernel()

    async with MCPStreamableHttpPlugin(
        name="MsLearn",
        url="https://learn.microsoft.com/api/mcp",
        description="MCP Stdio Plugin for MsLearn",
    ) as learn_mpc:
        kernel.add_plugin(learn_mpc, plugin_name="mslearn")

        agent = await create_agent(
            agent_name="MSLearnAgentWithMcp",
            agent_instructions="You are a helpful assistant. Use tools to solve user queries.",
            client=client,
            kernel=kernel,
            plugins=[learn_mpc],
        )

        thread = None
        user_input = "use mslearn to summarize SQL Server"
        thread = await test_agent(client, agent, user_input, thread)

asyncio.run(
    main()
)