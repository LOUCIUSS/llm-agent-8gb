# ============================================================
# 8GB LLM Agent — Makefile
# Phase 01: Environment Management Commands
# ============================================================

.PHONY: help setup install install-gpu clean test lint format deps-update \
        model-download model-list server cli venv docs

PYTHON := .venv/bin/python
PIP := .venv/bin/pip
PYTEST := .venv/bin/pytest
UVICORN := .venv/bin/uvicorn

# Default target
help:
	@echo "8GB LLM Agent — Available commands:"
	@echo ""
	@echo "  ${BOLD}Setup${NC}:"
	@echo "    make setup          Full environment setup (run once)"
	@echo "    make install        Install/update Python dependencies"
	@echo "    make install-gpu    Install with GPU (CUDA) support"
	@echo ""
	@echo "  ${BOLD}Development${NC}:"
	@echo "    make server         Start API server (localhost:11434)"
	@echo "    make cli            Start interactive CLI"
	@echo "    make test           Run all tests"
	@echo "    make lint           Run linter (ruff)"
	@echo "    make format         Format code (black)"
	@echo ""
	@echo "  ${BOLD}Models${NC}:"
	@echo "    make model-list     List available models"
	@echo "    make model-mistral  Download Mistral-7B (default)"
	@echo "    make model-qwen     Download Qwen2.5-7B (coding)"
	@echo "    make model-llama    Download Llama-3.1-8B"
	@echo ""
	@echo "  ${BOLD}Maintenance${NC}:"
	@echo "    make clean          Remove venv, cache, build artifacts"
	@echo "    make deps-update    Update requirements.txt from venv"
	@echo ""

# ── Setup ──
setup:
	chmod +x setup.sh && ./setup.sh

venv:
	python3 -m venv .venv
	$(PIP) install --upgrade pip setuptools wheel

# ── Dependencies ──
install: venv
	$(PIP) install -r requirements.txt

install-gpu: venv
	@echo "Installing with CUDA GPU support..."
	CMAKE_ARGS="-DLLAMA_CUDA=on" $(PIP) install llama-cpp-python --force-reinstall --no-cache-dir
	$(PIP) install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121
	$(PIP) install -r requirements.txt

# ── Model Management ──
model-list:
	@echo "Available models (GGUF Q4_K_M):"
	@echo "  mistral-7b     → ~4.1 GB · 32K ctx · Best all-around"
	@echo "  qwen2.5-7b     → ~4.5 GB · 128K ctx · Best coding"
	@echo "  llama-3.1-8b   → ~4.9 GB · 128K ctx · Meta flagship"
	@echo "  deepseek-7b    → ~4.5 GB · 32K ctx · Reasoning"
	@echo "  phi-3-medium   → ~2.5 GB · 128K ctx · Long context"

model-mistral:
	@echo "Downloading Mistral-7B-v0.3 Q4_K_M..."
	mkdir -p models
	$(PYTHON) scripts/download_model.py --model mistral-7b

model-qwen:
	@echo "Downloading Qwen2.5-7B Q4_K_M..."
	mkdir -p models
	$(PYTHON) scripts/download_model.py --model qwen2.5-7b

model-llama:
	@echo "Downloading Llama-3.1-8B Q4_K_M..."
	mkdir -p models
	$(PYTHON) scripts/download_model.py --model llama-3.1-8b

# ── Running ──
server:
	@echo "Starting API server on http://localhost:11434"
	$(UVICORN) api.server:app --host 0.0.0.0 --port 11434 --reload

cli:
	$(PYTHON) -m cli.main

# ── Development ──
test:
	$(PYTEST) tests/ -v --tb=short

lint:
	ruff check . --exclude .venv

format:
	black . --exclude .venv
	isort . --skip .venv

# ── Maintenance ──
clean:
	rm -rf .venv __pycache__ .pytest_cache .ruff_cache
	find . -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name "*.pyc" -delete
	@echo "Cleaned build artifacts. Virtual environment removed."

deps-update:
	$(PIP) freeze > requirements.lock.txt
	@echo "Locked dependencies to requirements.lock.txt"
