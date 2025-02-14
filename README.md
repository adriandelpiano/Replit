wget https://raw.githubusercontent.com/adriandelpiano/Replit/main/BOT/install.sh
```

2. Dale permisos de ejecución:
```bash
chmod +x install.sh
```

3. Ejecuta el instalador:
```bash
./install.sh
```

El instalador:
- Verificará que tengas Python 3.7+
- Instalará las dependencias necesarias
- Te pedirá el token de tu bot
- Configurará todo automáticamente

### 📦 Instalación Manual

1. Clona el repositorio:
```bash
git clone https://github.com/adriandelpiano/Replit.git
cd Replit/BOT
```

2. Instala las dependencias:
```bash
pip install python-telegram-bot==20.7
```

3. Configura el token del bot:
```bash
echo "BOT_TOKEN=tu_token_aqui" > .env
```

## 🔑 Obtener Token del Bot

1. Inicia una conversación con [@BotFather](https://t.me/botfather)
2. Envía el comando `/newbot`
3. Sigue las instrucciones para crear un nuevo bot:
   - Ingresa un nombre para tu bot
   - Elige un nombre de usuario (debe terminar en 'bot')
4. BotFather te proporcionará un token. ¡Guárdalo de forma segura!

## 🎮 Uso

1. Inicia el bot:
```bash
./start.sh