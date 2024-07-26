FROM python:3.11.9-bookworm AS builder
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

ENV OLLAMA_HOST "0.0.0.0"
# store models in a volume, see fly.toml
ENV OLLAMA_MODELS "/root/.ollama"

# install ollama and download llama2:7b
RUN curl -sSL https://ollama.com/install.sh | bash
RUN bash -c "ollama serve > /dev/null 2>&1 & until curl -s http://localhost:11434 > /dev/null; do echo 'Waiting for ollama...'; sleep 1; done && ollama pull llama2:7b"

WORKDIR /app

COPY requirements.txt .
RUN python -m venv .venv
RUN .venv/bin/pip install -r requirements.txt

COPY . .

FROM python:3.11-slim
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1
ENV OLLAMA_HOST "0.0.0.0"
ENV OLLAMA_MODELS "/root/.ollama"

RUN apt-get update -y && apt-get install -y curl

WORKDIR /app

RUN curl -sSL https://ollama.com/install.sh | bash

COPY --from=builder /app/.venv .venv/
COPY --from=builder /app /app

# transient models can be stored in the volume too
RUN mkdir -p /root/.ollama/model_cache/
RUN ln -s /root/.ollama/model_cache/ /root/.cache

# we did not copy this in the build stage
RUN curl -sSL https://ollama.com/install.sh | bash

RUN chmod a+x start.sh
CMD ["./start.sh"]
