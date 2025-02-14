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