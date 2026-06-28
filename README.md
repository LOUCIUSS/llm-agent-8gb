# 🤖 8GB LLM Agent — Local AI with Full Agent Features

> Run powerful 7B parameter LLMs locally on just **8GB RAM** — with vision, RAG memory, web search, ReAct tool use, document understanding, and LoRA fine-tuning. Ollama-compatible API server included.

---

## 🚀 Quick Start

```bash
# 1. Clone the repository
git clone https://github.com/LOUCIUSS/llm-agent-8gb.git
cd llm-agent-8gb

# 2. Run the setup (automated Phase 01)
chmod +x setup.sh && ./setup.sh

# 3. Activate the virtual environment
source .venv/bin/activate

# 4. Download a model
python scripts/download_model.py --model mistral-7b

# 5. Start the API server
make server
```

---

## 📋 What's Included (Phase 01: Environment Setup)

| Component | Package | Purpose |
|-----------|---------|---------|
| **Core Inference** | `llama-cpp-python` | CPU-optimized GGUF model loading with OpenBLAS |
| **Embeddings** | `sentence-transformers` | High-quality text embeddings (nomic-embed-text) |
| **API Server** | `fastapi` + `uvicorn` | Ollama-compatible REST API with streaming |
| **Web Search** | `duckduckgo-search` | Privacy-focused web search |
| **Vector Store** | `qdrant-client` | In-process vector database for RAG |
| **Documents** | `pymupdf` + `python-docx` | PDF, DOCX, TXT processing |
| **OCR** | `pytesseract` | Text extraction from images |
| **Vision** | `Pillow` | Image preprocessing for LLaVA |
| **CLI** | `rich` + `prompt_toolkit` | Beautiful terminal interface |
| **Logging** | `loguru` | Structured logging with rotation |
| **Config** | `pyyaml` | Profile-based configuration |

---

## 📁 Project Structure

```
llm-agent-8gb/
├── config.yaml           # Profile-based configuration (lite/full/coding)
├── setup.sh              # Automated environment setup
├── Makefile              # Common development commands
├── requirements.txt      # Python dependencies
├── README.md             # This file
│
├── core/                 # Model loading, inference, streaming
│   ├── __init__.py
│   ├── model_loader.py       # ModelLoader singleton with hot-swap
│   ├── generator.py          # Streaming text generation
│   ├── context_manager.py    # Dynamic context window management
│   ├── chat_template.py      # Auto-detect chat formats
│   └── benchmark.py          # Performance benchmarking
│
├── api/                  # Ollama-compatible REST API
│   ├── __init__.py
│   ├── server.py             # FastAPI application
│   ├── routes.py             # All API endpoints
│   ├── models.py             # Pydantic request/response schemas
│   └── auth.py               # Optional API key authentication
│
├── agent/                # ReAct tool-use agent system
│   ├── __init__.py
│   ├── tool_registry.py      # JSON Schema tool registration
│   ├── react_agent.py        # ReAct reasoning loop
│   ├── planner.py            # Multi-step task planning
│   └── tools/                # Built-in tool implementations
│
├── memory/               # Multi-tier memory system
│   ├── __init__.py
│   ├── short_term.py         # In-conversation turn buffer
│   ├── long_term.py          # SQLite message history
│   ├── semantic.py           # Qdrant vector search
│   ├── entity_extractor.py   # Named entity & fact extraction
│   └── summarizer.py         # Auto-session summarization
│
├── rag/                  # Document understanding & retrieval
│   ├── __init__.py
│   ├── document_processor.py # Multi-format document parsing
│   ├── chunker.py            # Semantic text chunking
│   ├── embedder.py           # Embedding + Qdrant storage
│   ├── retriever.py          # Hybrid vector + BM25 retrieval
│   └── citation.py           # Source citation in answers
│
├── vision/               # LLaVA vision model support
│   ├── __init__.py
│   ├── vision_loader.py      # Vision model loading
│   ├── image_processor.py    # Image preprocessing
│   └── vision_router.py      # Auto-route vision requests
│
├── cli/                  # Interactive terminal interface
│   ├── __init__.py
│   ├── main.py               # CLI entry point
│   ├── commands.py           # Slash command handlers
│   ├── display.py            # Rich console output
│   └── session.py            # Session management
│
├── finetune/             # LoRA fine-tuning (Phase 10)
│   ├── __init__.py
│   ├── dataset_builder.py    # JSONL dataset creation
│   ├── lora_trainer.py       # PEFT LoRA training
│   └── gguf_exporter.py      # Convert to GGUF format
│
├── tests/                # Test suite
│   ├── __init__.py
│   ├── test_inference.py
│   ├── test_api.py
│   ├── test_memory.py
│   └── test_rag.py
│
├── scripts/              # Utility scripts
│   └── download_model.py     # Model downloader
│
├── models/               # Downloaded GGUF models (gitignored)
├── data/                 # Runtime data (gitignored)
└── logs/                 # Log files (gitignored)
```

---

## ⚙️ Configuration Profiles

Three pre-configured profiles in `config.yaml`:

| Profile | Model | RAM | Context | Best For |
|---------|-------|-----|---------|----------|
| **lite** | Phi-3-medium (2.5GB) | ~5GB | 8K | Fast responses, simple tasks |
| **full** | Mistral-7B (4.1GB) | ~7GB | 32K | Best overall quality |
| **coding** | Qwen2.5-7B (4.5GB) | ~8GB | 16K | Code generation |

Switch profiles:
```bash
python -m cli.main --profile lite
make server  # uses default_profile from config.yaml
```

---

## 🛠️ System Requirements

| Requirement | Minimum |
|-------------|---------|
| **RAM** | 8 GB |
| **CPU** | 4+ cores recommended |
| **OS** | Linux (Ubuntu/Debian), macOS, WSL2 |
| **Python** | 3.10+ |
| **Disk** | 10 GB free (models + environment) |

### Install System Dependencies (Ubuntu/Debian)

```bash
sudo apt update && sudo apt install -y \
    build-essential cmake libopenblas-dev \
    pkg-config tesseract-ocr libtesseract-dev \
    git wget curl
```

---

## 📚 Roadmap Phases

| Phase | Feature | Est. Time | Status |
|-------|---------|-----------|--------|
| **01** | 🟢 Environment Setup | 2-3 days | **Complete** |
| 02 | Inference Core (7B) | 3-5 days | Pending |
| 03 | Ollama-compatible API | 4-5 days | Pending |
| 04 | ReAct Agent + Tools | 5-7 days | Pending |
| 05 | Memory System | 3-4 days | Pending |
| 06 | Document RAG | 4-5 days | Pending |
| 07 | Web Search | 2-3 days | Pending |
| 08 | Vision Support | 3-5 days | Pending |
| 09 | CLI + Web UI | 3-4 days | Pending |
| 10 | LoRA Fine-tuning | 5-7 days | Pending |
| 11 | Config, Logging, Polish | 2-3 days | Pending |

---

## 🔧 Development Commands

```bash
# Start API server (Ollama-compatible, port 11434)
make server

# Interactive CLI
make cli

# Run tests
make test

# Download models
make model-mistral   # ~4.1 GB - Best all-around
make model-qwen      # ~4.5 GB - Best coding
make model-llama     # ~4.9 GB - Meta flagship

# Lint and format
make lint
make format

# Clean everything
make clean
```

---

## 🧪 Testing the Setup

After running `setup.sh`:

```bash
# Test Python import
python -c "from llama_cpp import Llama; print('✓ llama-cpp-python OK')"

# Test sentence-transformers
python -c "from sentence_transformers import SentenceTransformer; print('✓ sentence-transformers OK')"

# Test FastAPI
python -c "from fastapi import FastAPI; print('✓ FastAPI OK')"

# Test Qdrant
python -c "from qdrant_client import QdrantClient; print('✓ Qdrant OK')"

# Run full test suite
make test
```

---

## 📦 Model Downloads

| Model | Size | Context | Download |
|-------|------|---------|----------|
| Mistral-7B-v0.3 | ~4.1 GB | 32K | `python scripts/download_model.py --model mistral-7b` |
| Qwen2.5-7B | ~4.5 GB | 128K | `python scripts/download_model.py --model qwen2.5-7b` |
| Llama-3.1-8B | ~4.9 GB | 128K | `python scripts/download_model.py --model llama-3.1-8b` |
| DeepSeek-R1-7B | ~4.5 GB | 32K | `python scripts/download_model.py --model deepseek-7b` |
| Phi-3-medium | ~2.5 GB | 128K | `python scripts/download_model.py --model phi-3-medium` |

---

## 🤝 API Compatibility

Once Phase 03 is complete, this server will be compatible with:

- **Ollama API** — Drop-in replacement for local Ollama
- **OpenAI API** — Use any OpenAI SDK with local models
- **Tools/Functions** — OpenAI-compatible function calling

```bash
# Ollama-compatible
 curl http://localhost:11434/api/generate -d '{"model":"mistral-7b","prompt":"Hello"}'

# OpenAI-compatible
 curl http://localhost:11434/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"model":"mistral-7b","messages":[{"role":"user","content":"Hello"}]}'
```

---

## 📄 License

MIT License — See [LICENSE](LICENSE) for details.

---

<p align="center">
  Built for 8GB RAM systems · CPU-optimized · Privacy-first · Fully local
</p>
