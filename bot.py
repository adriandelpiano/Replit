import logging
from telegram import Update
from telegram.ext import (
    Application,
    CommandHandler,
    MessageHandler,
    filters,
    ContextTypes,
)
from config import (
    WELCOME_MESSAGE,
    HELP_MESSAGE,
    START_MESSAGE,
    BOT_TOKEN
)
from logger import setup_logger

# Configurar el logger
logger = setup_logger()

async def start(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    """Maneja el comando /start"""
    user = update.effective_user
    logger.info(f"Comando /start recibido - Usuario: {user.id} ({user.first_name})")
    try:
        await update.message.reply_text(START_MESSAGE.format(user.first_name))
        logger.info(f"Mensaje /start enviado exitosamente a {user.id}")
    except Exception as e:
        logger.error(f"Error al enviar mensaje /start: {str(e)}")

async def help_command(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    """Maneja el comando /help"""
    user = update.effective_user
    logger.info(f"Comando /help recibido - Usuario: {user.id} ({user.first_name})")
    try:
        await update.message.reply_text(HELP_MESSAGE)
        logger.info(f"Mensaje /help enviado exitosamente a {user.id}")
    except Exception as e:
        logger.error(f"Error al enviar mensaje /help: {str(e)}")

async def welcome_new_members(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    """Da la bienvenida a nuevos miembros del grupo"""
    if update.message.new_chat_members:
        chat = update.message.chat
        logger.info(f"Nuevos miembros detectados en el grupo {chat.id} ({chat.title})")
        for new_member in update.message.new_chat_members:
            if not new_member.is_bot:
                logger.info(f"Dando bienvenida a {new_member.id} ({new_member.first_name})")
                try:
                    await update.message.reply_text(
                        WELCOME_MESSAGE.format(
                            new_member.first_name,
                            update.message.chat.title
                        )
                    )
                    logger.info(f"Mensaje de bienvenida enviado exitosamente para {new_member.id}")
                except Exception as e:
                    logger.error(f"Error al enviar mensaje de bienvenida: {str(e)}")

async def handle_message(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    """Maneja mensajes directos al bot"""
    if update.message.chat.type == "private":
        user = update.effective_user
        logger.info(f"Mensaje privado recibido de {user.id} ({user.first_name})")
        try:
            await update.message.reply_text(
                "¡Hola! Soy un bot de bienvenida. Añádeme a un grupo para dar la bienvenida a nuevos miembros."
            )
            logger.info(f"Respuesta a mensaje privado enviada exitosamente a {user.id}")
        except Exception as e:
            logger.error(f"Error al responder mensaje privado: {str(e)}")

def main() -> None:
    """Función principal para iniciar el bot"""
    try:
        if not BOT_TOKEN:
            logger.error("No se encontró el token del bot en las variables de entorno")
            return

        logger.info("Iniciando bot con la configuración...")
        application = Application.builder().token(BOT_TOKEN).build()

        # Añadir handlers
        logger.info("Configurando handlers...")
        application.add_handler(CommandHandler("start", start))
        application.add_handler(CommandHandler("help", help_command))
        application.add_handler(MessageHandler(filters.StatusUpdate.NEW_CHAT_MEMBERS, welcome_new_members))
        application.add_handler(MessageHandler(filters.ChatType.PRIVATE & filters.TEXT, handle_message))

        # Iniciar el bot
        logger.info("Bot configurado exitosamente, iniciando polling...")
        application.run_polling(allowed_updates=Update.ALL_TYPES)

    except Exception as e:
        logger.error(f"Error crítico al iniciar el bot: {str(e)}")
        raise

if __name__ == '__main__':
    main()