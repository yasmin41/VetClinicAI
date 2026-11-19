# VetClinicAI 🐾

**AI-Powered Veterinary Clinic Automation System**

VetClinicAI is a veterinary clinic automation project that combines **n8n, Microsoft SQL Server, Google Gemini AI, Python, Discord, and Docker** to automate vaccination reminders and provide a conversational AI assistant for clinic staff.

The project demonstrates workflow automation, AI agent integration, database connectivity, and containerized deployment.

## Key Features

### 1. Automated Vaccination Reminders

- Retrieves upcoming pet vaccinations from Microsoft SQL Server.
- Identifies vaccinations due within the next seven days.
- Generates reminder messages containing relevant vaccination information.
- Sends notifications to a dedicated Discord channel.
- Uses reminder history to prevent duplicate notifications.

### 2. AI-Powered Clinic Assistant

- Allows users to ask questions through a dedicated Discord channel.
- Uses Google Gemini to interpret natural-language questions.
- Retrieves upcoming vaccination information using an n8n Microsoft SQL tool.
- Returns AI-generated responses directly to Discord.
- Supports an additional n8n chat interface for testing.

### 3. Docker-Based Deployment

- Runs n8n and the Python Discord Bot as Docker Compose services.
- Uses Docker networking for communication between containers.
- Supports environment-based configuration.
- Preserves n8n data using a Docker volume.

## Technology Stack

| Technology | Purpose |
|---|---|
| n8n | Workflow automation and AI agent orchestration |
| Microsoft SQL Server | Relational database |
| Google Gemini | Large language model |
| Python | Discord Bot implementation |
| discord.py | Discord messaging integration |
| aiohttp | Asynchronous HTTP communication |
| Docker | Containerization |
| Docker Compose | Multi-container orchestration |
| Git & GitHub | Version control and project hosting |

## System Architecture

### AI Assistant

```text
Discord User
    |
    v
Discord Bot (Python)
    |
    v
n8n Authenticated Webhook
    |
    v
Gemini AI Agent
    |
    v
Microsoft SQL Tool
    |
    v
SQL Server Database
    |
    v
Gemini AI Agent
    |
    v
Webhook Response
    |
    v
Discord Bot
    |
    v
Discord User
```

### Vaccination Reminder Automation

```text
Schedule Trigger
    |
    v
SQL Server Query
    |
    v
Filter Upcoming Vaccinations
    |
    v
Prepare Reminder Message
    |
    v
Check Reminder History
    |
    v
Send Discord Notification
    |
    v
Log Sent Reminder
```

## Database Design

The system uses Microsoft SQL Server with the following main tables:

| Table | Description |
|---|---|
| Customers | Stores pet owner information |
| Pets | Stores pet details and customer relationships |
| Vaccinations | Stores vaccination records and due dates |
| Appointments | Stores appointment records |
| VaccinationReminderLog | Tracks previously sent vaccination reminders |

The database scripts are located in the `database/` directory.

## Project Structure

```text
VetClinicAI/
|
|-- database/
|   |-- create-schema.sql
|   |-- create-vaccination-reminder-log.sql
|   |-- seed-data.sql
|   |-- test-data.sql
|
|-- workflows/
|   |-- VetClinicAI - 01 - SQL Server Connection Test.json
|   |-- VetClinicAI - 02 - Vaccination Reminder.json
|   |-- VetClinicAI - 03 - AI Clinic Assistant.json
|   |-- README.md
|
|-- discord-bot/
|   |-- bot.py
|   |-- requirements.txt
|   |-- Dockerfile
|
|-- .env.example
|-- .gitignore
|-- compose.yaml
|-- README.md
```

## Installation and Setup

### Prerequisites

- Docker Desktop with Docker Compose
- Microsoft SQL Server
- A Discord server with a configured bot
- Google Gemini API credentials
- Git

### 1. Clone the Repository

```bash
git clone https://github.com/yasmin41/VetClinicAI.git
cd VetClinicAI
```

### 2. Configure Environment Variables

Create a `.env` file based on `.env.example`.

Configure the following variables:

```dotenv
N8N_PORT=5679
GENERIC_TIMEZONE=Asia/Amman
TZ=Asia/Amman

DISCORD_BOT_TOKEN=YOUR_DISCORD_BOT_TOKEN
DISCORD_CHANNEL_ID=YOUR_DISCORD_CHANNEL_ID

N8N_WEBHOOK_API_KEY=YOUR_WEBHOOK_SECRET_KEY
```

Never commit real API keys, bot tokens, or database passwords to GitHub.

### 3. Start Docker Services

```bash
docker compose up -d --build
```

Check service status:

```bash
docker compose ps
```

Open the n8n editor:

`http://localhost:5679`

### 4. Configure SQL Server

1. Create the `VetClinicAI` database.
2. Run the database schema scripts from `database/`.
3. Insert the provided sample data for testing.
4. Configure SQL Server network connectivity for n8n.
5. Create a dedicated database login with appropriate permissions.
6. Configure the Microsoft SQL credentials inside n8n.

For the AI Assistant, use a database account with read-only access.

The development environment uses `host.docker.internal` to connect from Docker to SQL Server running on the Windows host.

### 5. Configure n8n

Import the JSON files from the `workflows/` directory.

Configure the required credentials:

- Microsoft SQL Server
- Google Gemini API
- Discord notification integration
- Header Authentication for the AI Assistant Webhook

Ensure that the Webhook authentication key matches `N8N_WEBHOOK_API_KEY` in the local `.env` file.

Publish the AI Assistant workflow to enable its production Webhook endpoint.

The Python Discord Bot communicates with n8n using the internal Docker service address:

`http://n8n:5678/webhook/discord-ai-chat`

### 6. Configure Discord

Create dedicated Discord channels for:

- Vaccination reminders
- AI clinic assistant

Invite the Discord Bot to the server and grant only the permissions it needs.

Enable **Message Content Intent** in the Discord Developer Portal.

Configure `DISCORD_CHANNEL_ID` with the ID of the assistant channel.

## n8n Workflows

### Workflow 01 — SQL Server Connection Test

Verifies connectivity between n8n and Microsoft SQL Server.

### Workflow 02 — Vaccination Reminder

Automates the process of identifying upcoming vaccinations, preparing reminder messages, checking reminder history, and sending Discord notifications.

### Workflow 03 — AI Clinic Assistant

Processes natural-language questions received through Discord or the n8n chat interface.

The Gemini AI Agent uses a predefined SQL query to retrieve vaccinations due within the next seven days.

The response is returned to the Discord user through the authenticated Webhook integration.

## Security

VetClinicAI incorporates several security measures:

- Environment variables for sensitive configuration.
- Git exclusions for local secrets.
- Header Authentication for the n8n Webhook.
- Discord Channel ID verification.
- Read-only database access for the AI Assistant.
- A predefined SQL query rather than unrestricted AI-generated SQL.
- Local Docker networking for internal service communication.

The included configuration is intended for local development and demonstration. Production deployment requires additional security hardening.

## Testing and Validation

The following scenarios were successfully tested in the development environment:

| Test | Result |
|---|---|
| SQL Server connectivity from n8n | Passed |
| Upcoming vaccination retrieval | Passed |
| Discord vaccination notifications | Passed |
| Reminder duplicate prevention | Passed |
| Gemini AI Agent with SQL Tool | Passed |
| Discord Bot message reception | Passed |
| Authenticated n8n Webhook integration | Passed |
| Discord AI question-and-answer flow | Passed |
| Docker Compose deployment | Passed |

## Current Limitations

- The AI Assistant currently retrieves upcoming vaccinations within a seven-day window.
- The assistant does not independently verify scheduled appointments.
- Vaccination due dates must not be interpreted as confirmed clinic bookings.
- The current deployment is designed for local development and demonstration.
- SQL Server and external service credentials must be configured separately.

## Future Improvements

Potential future enhancements include appointment lookup, additional database tools, role-based access control, deployment monitoring, and expanded AI assistant capabilities.

## Project Status

**Functional prototype — implemented and tested locally.**

The project demonstrates the integration of AI agents, workflow automation, relational databases, Discord messaging, and Docker-based services.

---

**VetClinicAI — Smarter Veterinary Clinic Automation**
