# Example: Inference using Semantic Kernel
from semantic_kernel import Kernel
import asyncio
from setup import get_project_client, test_agent, create_agent_chat_completions
from semantic_kernel.connectors.mcp import MCPStdioPlugin

async def main():
    client = await get_project_client()

    kernel = Kernel()

    async with MCPStdioPlugin(
        name="Postgres",
        command="uvx",
        args=["postgres-mcp", "--access-mode=unrestricted"],
        description="MCP Stdio Plugin for Postgres",
        env={
            "DATABASE_URI": "postgres://postgres:123456@localhost:5432"
        },
        version="1.0.0",
    ) as postgres_mpc:
        kernel.add_plugin(postgres_mpc, plugin_name="postgres_mcp")

        agent = await create_agent_chat_completions(
            agent_name="PGAgentWithMcp",
            agent_instructions="""You are a helpful assistant. Use tools to solve user queries. Think deep. Perform analysis. You may need to make multiple tool calls. 

            Do not stop until user request is fully satisfied.

            User is technical and should be notified if there are any issues connecting to the database or running queries.
            """,
            client=client,
            kernel=kernel,
            plugins=[postgres_mpc],
        )

        thread = None
        user_input = "analyze the schema of the movie database (public schema) find top 5 interesting insights and generate a report using tables and emojis"
        thread = await test_agent(client, agent, user_input, thread)

asyncio.run(
    main()
)