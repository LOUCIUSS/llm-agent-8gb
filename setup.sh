#!/usr/bin/env bash
# ============================================================
# 8GB LLM Agent - Environment Setup Script
# Phase 01: Complete Environment Bootstrap
# ============================================================
# Usage: chmod +x setup.sh && ./setup.sh
# Requirements: Python 3.10+, pip, git, build-essential
# ============================================================

set -euo pipefail

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# --- Config ---
PYTHON_MIN_VERSION="3.10"
VENV_DIR=".venv"
PROJECT_NAME="llm-agent-8gb"

# --- Helpers ---
log_info()  { echo -e "${BLUE}[INFO]${NC}  $1"; }
log_ok()    { echo -e "${GREEN}[OK]${NC}    $1"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC}  $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_step()  { echo -e "\n${BOLD}${CYAN}▶ $1${NC}"; }

# --- Phase 1.1: Python Version Check ---
check_python() {
    log_step "Phase 1.1: Checking Python environment"

    if ! command -v python3 &>/dev/null; then
        log_error "python3 not found. Install Python ${PYTHON_MIN_VERSION}+ first:"
        echo "  sudo apt update && sudo apt install -y python3 python3-pip python3-venv"
        exit 1
    fi

    PYTHON_VERSION=$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')
    log_info "Found Python ${PYTHON_VERSION}"

    if python3 -c "import sys; exit(0 if sys.version_info >= (3,10) else 1)"; then
        log_ok "Python version >= ${PYTHON_MIN_VERSION} ✓"
    else
        log_error "Python ${PYTHON_VERSION} is too old. Need ${PYTHON_MIN_VERSION}+"
        exit 1
    fi

    # Check CPU threads (for llama.cpp n_threads config)
    CPU_THREADS=$(nproc 2>/dev/null || echo "unknown")
    log_info "CPU threads detected: ${CPU_THREADS} → set n_threads=${CPU_THREADS} in config"
}

# --- System Dependencies ---
install_system_deps() {
    log_step "Installing system dependencies"

    if command -v apt-get &>/dev/null; then
        log_info "Detected Debian/Ubuntu system"
        sudo apt-get update -qq
        sudo apt-get install -y -qq \
            build-essential \
            cmake \
            libopenblas-dev \
            pkg-config \
            tesseract-ocr \
            libtesseract-dev \
            git \
            wget \
            curl \
            2>&1 | grep -v "^Selecting\|^Preparing\|^Unpacking\|^Setting up\|^Processing" || true
        log_ok "System packages installed ✓"
    else
        log_warn "Non-Debian system detected. Please install manually:"
        echo "  - build-essential / base-devel"
        echo "  - cmake"
        echo "  - OpenBLAS development headers"
        echo "  - Tesseract OCR + development headers"
    fi
}

# --- Virtual Environment ---
setup_venv() {
    log_step "Phase 1.1: Creating Python virtual environment"

    if [ -d "${VENV_DIR}" ]; then
        log_warn "Virtual environment already exists at ./${VENV_DIR}"
        read -p "  Recreate? [y/N] " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf "${VENV_DIR}"
            python3 -m venv "${VENV_DIR}"
            log_ok "Virtual environment recreated ✓"
        else
            log_info "Using existing virtual environment"
        fi
    else
        python3 -m venv "${VENV_DIR}"
        log_ok "Virtual environment created at ./${VENV_DIR} ✓"
    fi

    # Activate
    source "${VENV_DIR}/bin/activate"
    log_info "Virtual environment activated"
    log_info "Python: $(which python3)"
    log_info "Pip: $(pip --version)"
}

# --- Phase 1.2: llama-cpp-python with OpenBLAS ---
install_llama_cpp() {
    log_step "Phase 1.2: Installing llama-cpp-python with OpenBLAS"
    log_info "This enables CPU-optimized matrix operations"
    log_info "Build may take 5-15 minutes depending on your CPU..."

    CMAKE_ARGS="-DLLAMA_BLAS=ON -DLLAMA_BLAS_VENDOR=OpenBLAS" \
        pip install llama-cpp-python --no-cache-dir -q

    log_ok "llama-cpp-python installed with OpenBLAS ✓"
}

# --- Phase 1.3: Sentence Transformers ---
install_embeddings() {
    log_step "Phase 1.3: Installing sentence-transformers"
    pip install sentence-transformers -q
    log_ok "sentence-transformers installed ✓"
    log_info "First run will download ~400MB for nomic-embed-text model"
}

# --- Phase 1.4: API Server Stack ---
install_api_stack() {
    log_step "Phase 1.4: Installing API server + agent stack"
    pip install \
        fastapi "uvicorn[standard]" \
        pydantic sse-starlette \
        duckduckgo-search requests beautifulsoup4 \
        psutil -q
    log_ok "API server stack installed ✓"
}

# --- Phase 1.5: Vector Store + Document Processing ---
install_vector_docs() {
    log_step "Phase 1.5: Installing vector store + document processing"
    pip install \
        qdrant-client pymupdf python-docx \
        pytesseract rank-bm25 huggingface_hub -q
    log_ok "Vector store + docs stack installed ✓"
}

# --- Phase 1.6: Vision + CLI + Utils ---
install_vision_cli() {
    log_step "Phase 1.6: Installing vision + CLI + utilities"
    pip install \
        Pillow rich prompt_toolkit typer \
        loguru pyyaml pytest numexpr -q
    log_ok "Vision + CLI + utils installed ✓"
}

# --- Phase 1.7: Project Layout Verification ---
verify_layout() {
    log_step "Phase 1.7: Verifying project layout"

    local dirs=("core" "api" "agent" "memory" "rag" "vision" "cli" "finetune" "tests" "models" "scripts" "docs")
    local all_ok=true

    for dir in "${dirs[@]}"; do
        if [ -d "$dir" ]; then
            touch "${dir}/__init__.py"
            log_ok "  ${dir}/ ✓"
        else
            log_error "  ${dir}/ MISSING"
            all_ok=false
        fi
    done

    if $all_ok; then
        log_ok "Project layout verified ✓"
    else
        log_error "Some directories are missing. Run this script from the project root."
        exit 1
    fi
}

# --- Post-Install Summary ---
print_summary() {
    echo -e "\n${BOLD}${GREEN}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${GREEN}║        Environment Setup Complete!                       ║${NC}"
    echo -e "${BOLD}${GREEN}╚══════════════════════════════════════════════════════════╝${NC}"
    echo
    echo -e "${BOLD}Project:${NC}      ${PROJECT_NAME}"
    echo -e "${BOLD}Python:${NC}       $(python3 --version)"
    echo -e "${BOLD}Venv:${NC}         $(pwd)/${VENV_DIR}"
    echo -e "${BOLD}CPU Threads:${NC}  ${CPU_THREADS}"
    echo
    echo -e "${BOLD}Installed packages:${NC}"
    echo "  • llama-cpp-python (with OpenBLAS)"
    echo "  • sentence-transformers (~400MB model download on first use)"
    echo "  • FastAPI + uvicorn + pydantic + sse-starlette"
    echo "  • duckduckgo-search + requests + beautifulsoup4"
    echo "  • Qdrant client + PyMuPDF + python-docx + pytesseract"
    echo "  • Pillow + rich + prompt_toolkit + typer + loguru"
    echo "  • PyYAML + pytest + numexpr"
    echo
    echo -e "${BOLD}Project structure:${NC}"
    find . -maxdepth 2 -type d -not -path './.venv/*' -not -path './.git/*' | sort | sed 's|^\.||' | sed 's|^|  |'
    echo
    echo -e "${BOLD}${CYAN}Next steps:${NC}"
    echo "  1. Activate venv:  source ${VENV_DIR}/bin/activate"
    echo "  2. Download a model:  python scripts/download_model.py --model mistral-7b"
    echo "  3. Start the API:  python -m api.server"
    echo "  4. Or use the CLI:  python -m cli.main"
    echo
    echo -e "${YELLOW}Tip:${NC} Edit config.yaml to switch between 'lite' and 'full' profiles"
}

# ============================================================
# MAIN
# ============================================================
main() {
    echo -e "${BOLD}"
    echo "  ██╗     ██╗     ███╗   ███╗         █████╗  ██████╗ ███████╗███╗   ██╗████████╗"
    echo "  ██║     ██║     ████╗ ████║        ██╔══██╗██╔════╝ ██╔════╝████╗  ██║╚══██╔══╝"
    echo "  ██║     ██║     ██╔████╔██║        ███████║██║  ███╗█████╗  ██╔██╗ ██║   ██║   "
    echo "  ██║     ██║     ██║╚██╔╝██║        ██╔══██║██║   ██║██╔══╝  ██║╚██╗██║   ██║   "
    echo "  ███████╗███████╗██║ ╚═╝ ██║███████╗██║  ██║╚██████╔╝███████╗██║ ╚████║   ██║   "
    echo "  ╚══════╝╚══════╝╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚═╝  ╚═══╝   ╚═╝   "
    echo -e "${NC}"
    echo -e "  ${BOLD}8GB RAM Local LLM Agent — Phase 01: Environment Setup${NC}"
    echo -e "  ${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo

    check_python
    install_system_deps
    setup_venv
    install_llama_cpp
    install_embeddings
    install_api_stack
    install_vector_docs
    install_vision_cli
    verify_layout
    print_summary
}

main "$@"
