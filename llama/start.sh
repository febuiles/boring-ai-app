#!/usr/bin/env bash

ollama serve & until curl -s http://localhost:11434 > /dev/null; do echo 'Waiting for ollama...'; sleep 1; done && ollama run llama2:7b ""

/app/.venv/bin/uvicorn server:app --host 0.0.0.0 --port 8080
