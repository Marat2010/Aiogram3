#!/home/marat/Aiogram3/venv/bin/python3
"""
This example shows how to use webhook on behind of any reverse proxy (nginx, traefik, ingress etc.)
"""
import logging
import ssl
import sys
from os import getenv

from aiohttp import web

from aiogram import Bot, Dispatcher, Router, types
from aiogram.enums import ParseMode
from aiogram.filters import CommandStart
from aiogram.types import FSInputFile, Message
from aiogram.utils.markdown import hbold
from aiogram.webhook.aiohttp_server import SimpleRequestHandler, setup_application

SELF_SSL = False

# Bot token can be obtained via https://t.me/BotFather
TOKEN = getenv("BOT_TOKEN")

# Path to webhook route, on which Telegram will send requests
WEBHOOK_PATH = "/" + getenv("PROJECT_NAME")

DOMAIN = getenv("DOMAIN_IP") if SELF_SSL else getenv("DOMAIN_NAME")
EXTERNAL_PORT = 8443

# Base URL for webhook will be used to generate webhook URL for Telegram,
# in this example it is used public DNS with HTTPS support
# BASE_WEBHOOK_URL = "https://aiogram.dev/"
BASE_WEBHOOK_URL = "https://" + DOMAIN + ":" + str(EXTERNAL_PORT)

if SELF_SSL:
    WEB_SERVER_HOST = DOMAIN
    WEB_SERVER_PORT = EXTERNAL_PORT
else:
    # Webserver settings
    # bind localhost only to prevent any external access
    WEB_SERVER_HOST = "127.0.0.1"
    # Port for incoming request from reverse proxy. Should be any available port
    WEB_SERVER_PORT = 8080

# Secret key to validate requests from Telegram (optional)
WEBHOOK_SECRET = "my-secret"

# ========= For self-signed certificate =======
# Path to SSL certificate and private key for self-signed certificate.
# WEBHOOK_SSL_CERT = "/path/to/cert.pem"
# WEBHOOK_SSL_PRIV = "/path/to/private.key"
if SELF_SSL:
    WEBHOOK_SSL_CERT = "../SSL/" + DOMAIN + ".self.crt"
    WEBHOOK_SSL_PRIV = "../SSL/" + DOMAIN + ".self.key"

# All handlers should be attached to the Router (or Dispatcher)
router = Router()


@router.message(CommandStart())
async def command_start_handler(message: Message) -> None:
    """
    This handler receives messages with `/start` command
    """
    # Most event objects have aliases for API methods that can be called in events' context
    # For example if you want to answer to incoming message you can use `message.answer(...)` alias
    # and the target chat will be passed to :ref:`aiogram.methods.send_message.SendMessage`
    # method automatically or call API method directly via
    # Bot instance: `bot.send_message(chat_id=message.chat.id, ...)`
    await message.answer(f"Hello, {hbold(message.from_user.full_name)}!")


@router.message()
async def echo_handler(message: types.Message) -> None:
    """
    Handler will forward receive a message back to the sender

    By default, message handler will handle all message types (like text, photo, sticker etc.)
    """
    try:
        # Send a copy of the received message
        await message.send_copy(chat_id=message.chat.id)
    except TypeError:
        # But not all the types is supported to be copied so need to handle it
        await message.answer("Nice try!")


async def on_startup(bot: Bot) -> None:
    if SELF_SSL:
        # In case when you have a self-signed SSL certificate, you need to send the certificate
        # itself to Telegram servers for validation purposes
        # (see https://core.telegram.org/bots/self-signed)
        # But if you have a valid SSL certificate, you SHOULD NOT send it to Telegram servers.
        await bot.set_webhook(
            f"{BASE_WEBHOOK_URL}{WEBHOOK_PATH}",
            certificate=FSInputFile(WEBHOOK_SSL_CERT),
            secret_token=WEBHOOK_SECRET,
        )
    else:
        await bot.set_webhook(f"{BASE_WEBHOOK_URL}{WEBHOOK_PATH}", secret_token=WEBHOOK_SECRET)


# === (Added) Register shutdown hook to initialize webhook ===
async def on_shutdown(bot: Bot) -> None:
    """
    Graceful shutdown. This method is recommended by aiohttp docs.
    """
    # Remove webhook.
    await bot.delete_webhook()


def main() -> None:
    # Dispatcher is a root router
    dp = Dispatcher()
    # ... and all other routers should be attached to Dispatcher
    dp.include_router(router)

    # Register startup hook to initialize webhook
    dp.startup.register(on_startup)
    # === (Added) Register shutdown hook to initialize webhook
    dp.shutdown.register(on_shutdown)

    # Initialize Bot instance with a default parse mode which will be passed to all API calls
    bot = Bot(TOKEN, parse_mode=ParseMode.HTML)

    # Create aiohttp.web.Application instance
    app = web.Application()

    # Create an instance of request handler,
    # aiogram has few implementations for different cases of usage
    # In this example we use SimpleRequestHandler which is designed to handle simple cases
    webhook_requests_handler = SimpleRequestHandler(
        dispatcher=dp,
        bot=bot,
        secret_token=WEBHOOK_SECRET,
    )
    # Register webhook handler on application
    webhook_requests_handler.register(app, path=WEBHOOK_PATH)

    # Mount dispatcher startup and shutdown hooks to aiohttp application
    setup_application(app, dp, bot=bot)

    if SELF_SSL:  # ==== For self-signed certificate ====
        # Generate SSL context
        context = ssl.SSLContext(ssl.PROTOCOL_TLSv1_2)
        context.load_cert_chain(WEBHOOK_SSL_CERT, WEBHOOK_SSL_PRIV)

        # And finally start webserver
        web.run_app(app, host=WEB_SERVER_HOST, port=WEB_SERVER_PORT, ssl_context=context)
    else:
        # And finally start webserver
        web.run_app(app, host=WEB_SERVER_HOST, port=WEB_SERVER_PORT)


if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO, stream=sys.stdout)
    main()

# ================ Creating a self-signed certificate =============================
# openssl req -newkey rsa:2048 -sha256 -nodes -keyout SSL/PRIVATE_self.key -x509 -days 365
# -out SSL/PUBLIC_self.pem -subj "/C=RU/ST=RT/L=KAZAN/O=Home/CN=217.18.63.197"
# =============== For values from .env file ============================================
# from dotenv import load_dotenv, dotenv_values
# config = dotenv_values(".env_dev")
# DOMAIN = config['DOMAIN_NAME']
# FROM_ENV_FILE = True
# =================================================================================
# from decouple import AutoConfig
# config = AutoConfig()
# =================================================================================

