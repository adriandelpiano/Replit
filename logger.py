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
