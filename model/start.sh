#!/usr/bin/env bash

mkdir -p /data

/bin/ollama serve & until curl -s http://localhost:11434 > /dev/null; do echo 'Waiting for ollama...'; sleep 1; done && ollama pull llama3

/app/.venv/bin/uvicorn server:app --host 0.0.0.0
