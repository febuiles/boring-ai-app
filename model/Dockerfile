FROM ollama/ollama:latest AS ollama

FROM python:3.11.9-bookworm AS builder

ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1
ENV OLLAMA_HOST "0.0.0.0"
ENV OLLAMA_MODELS "/data"

COPY --from=ollama / /

WORKDIR /app

COPY . .

RUN apt-get update -y && apt-get install -y build-essential git curl \
    && apt-get clean && rm -f /var/lib/apt/lists/*_*

RUN python -m venv .venv
RUN .venv/bin/pip install -r requirements.txt

RUN chmod +x start.sh
CMD ["./start.sh"]
