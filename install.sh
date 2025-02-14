#!/bin/bash

echo "=== Instalador del Bot de Bienvenida para Telegram ==="
echo "Este script instalará todas las dependencias necesarias y configurará el bot."

# Verificar si Python está instalado
if ! command -v python3 &> /dev/null; then
    echo "Error: Python 3 no está instalado"
    echo "Por favor, instala Python 3.7 o superior"
    exit 1
fi

# Verificar versión de Python de manera más simple y robusta
python_version=$(python3 -V 2>&1 | cut -d' ' -f2)
if ! python3 -c "import sys; assert sys.version_info >= (3, 7), 'Python >= 3.7 required'"; then
    echo "Error: Se requiere Python 3.7 o superior"
    echo "Versión actual: $python_version"
    exit 1
fi
echo "✓ Python $python_version detectado"

# Crear directorio del proyecto si no existe
PROJECT_DIR="telegram_welcome_bot"
mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR" || exit 1

# Copiar archivos del proyecto
echo "Copiando archivos del proyecto..."

# bot.py
cat > bot.py << 'EOL'
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
EOL

# config.py
cat > config.py << 'EOL'
import os

# Token del bot desde variables de entorno
BOT_TOKEN = os.getenv('BOT_TOKEN')

# Mensajes configurables
WELCOME_MESSAGE = """
¡Bienvenido/a {0} al grupo {1}! 👋

Esperamos que disfrutes tu estancia aquí. 
No dudes en presentarte y participar en las conversaciones.
"""

START_MESSAGE = """
¡Hola {0}! 👋
Soy un bot de bienvenida para grupos de Telegram.
Añádeme a un grupo y daré la bienvenida a los nuevos miembros.

Usa /help para ver los comandos disponibles.
"""

HELP_MESSAGE = """
Comandos disponibles:

/start - Inicia el bot
/help - Muestra este mensaje de ayuda

Para usar el bot:
1. Añade el bot a un grupo
2. Dale permisos de administrador
3. ¡Listo! El bot dará la bienvenida a los nuevos miembros
"""
EOL

# logger.py
cat > logger.py << 'EOL'
import logging
from logging.handlers import RotatingFileHandler
import os

def setup_logger():
    """Configura y retorna un logger"""
    # Crear el directorio logs si no existe
    if not os.path.exists('logs'):
        os.makedirs('logs')

    # Configurar el logger
    logger = logging.getLogger('WelcomeBot')
    logger.setLevel(logging.INFO)

    # Crear un manejador para archivo con rotación
    file_handler = RotatingFileHandler(
        'logs/bot.log',
        maxBytes=1024 * 1024,  # 1MB
        backupCount=5
    )
    file_handler.setLevel(logging.INFO)

    # Crear un manejador para consola
    console_handler = logging.StreamHandler()
    console_handler.setLevel(logging.INFO)

    # Crear el formato para los logs
    formatter = logging.Formatter(
        '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
    )
    file_handler.setFormatter(formatter)
    console_handler.setFormatter(formatter)

    # Añadir los manejadores al logger
    logger.addHandler(file_handler)
    logger.addHandler(console_handler)

    return logger
EOL

# Instalar dependencias
echo "Instalando dependencias..."
python3 -m pip install --upgrade pip
python3 -m pip install "python-telegram-bot==20.7"

# Solicitar token del bot
while true; do
    echo -e "\nPara configurar el bot, necesitas un token de Telegram."
    echo "Puedes obtener uno hablando con @BotFather en Telegram y siguiendo estos pasos:"
    echo "1. Inicia una conversación con @BotFather"
    echo "2. Usa el comando /newbot"
    echo "3. Sigue las instrucciones para crear un nuevo bot"
    echo -e "\nCuando tengas el token, ingrésalo a continuación (o presiona Ctrl+C para cancelar):"
    read -r bot_token

    if [ -n "$bot_token" ]; then
        # Crear archivo .env con el token
        echo "BOT_TOKEN=$bot_token" > .env
        break
    else
        echo "El token no puede estar vacío. Por favor, inténtalo de nuevo."
    fi
done

# Crear directorio de logs
mkdir -p logs

# Crear script de inicio
cat > start.sh << 'EOL'
#!/bin/bash
export $(cat .env | xargs)
python3 bot.py
EOL

chmod +x start.sh

echo -e "\n=== Instalación completada ==="
echo "✓ Python y dependencias instaladas"
echo "✓ Token configurado en .env"
echo "✓ Directorio de logs creado"
echo "✓ Script de inicio preparado"
echo -e "\nPara iniciar el bot, ejecuta: ./start.sh"
echo "Los logs se guardarán en el directorio logs/"