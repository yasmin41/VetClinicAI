
import asyncio
import logging
import os

import aiohttp
import discord
from dotenv import load_dotenv

load_dotenv()

DISCORD_BOT_TOKEN = os.getenv("DISCORD_BOT_TOKEN")
DISCORD_CHANNEL_ID = int(os.getenv("DISCORD_CHANNEL_ID", "0"))
N8N_WEBHOOK_URL = os.getenv("N8N_WEBHOOK_URL")
N8N_WEBHOOK_API_KEY = os.getenv("N8N_WEBHOOK_API_KEY")

if not all([
    DISCORD_BOT_TOKEN,
    DISCORD_CHANNEL_ID,
    N8N_WEBHOOK_URL,
    N8N_WEBHOOK_API_KEY,
]):
    raise ValueError("Missing required environment variables.")

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("vetclinicai.discord")

intents = discord.Intents.default()
intents.message_content = True

client = discord.Client(intents=intents)


@client.event
async def on_ready():
    logger.info("VetClinicAI Bot is online as %s", client.user)


@client.event
async def on_message(message):
    if message.author.bot:
        return

    if message.channel.id != DISCORD_CHANNEL_ID:
        return

    question = message.content.strip()

    if not question:
        return

    headers = {
        "X-VetClinicAI-Key": N8N_WEBHOOK_API_KEY
    }

    payload = {
        "chatInput": question,
        "sessionId": str(message.author.id)
    }

    timeout = aiohttp.ClientTimeout(total=60)

    try:
        async with message.channel.typing():
            async with aiohttp.ClientSession(
                timeout=timeout
            ) as session:
                async with session.post(
                    N8N_WEBHOOK_URL,
                    json=payload,
                    headers=headers
                ) as response:
                    response.raise_for_status()
                    data = await response.json()

        answer = data.get("output", "No response from AI.")

        for start in range(0, len(answer), 1900):
            await message.reply(
                answer[start:start + 1900],
                mention_author=False,
                allowed_mentions=discord.AllowedMentions.none()
            )

    except (aiohttp.ClientError, asyncio.TimeoutError):
        logger.exception("Failed to contact n8n.")
        await message.reply(
            "Sorry, the clinic assistant is temporarily unavailable.",
            mention_author=False,
            allowed_mentions=discord.AllowedMentions.none()
        )


client.run(DISCORD_BOT_TOKEN)
