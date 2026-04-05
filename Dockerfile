# =========================
# Production Dockerfile
# =========================
FROM python:3.11-slim AS production

# Metadata
LABEL maintainer="thuleseeker"
LABEL description="Homepage API - FastAPI-based customizable homepage with cards"
LABEL version="1.0.0"

# Environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PORT=8000 \
    PYTHONPATH=/app/backend

# Working directory
WORKDIR /app

# Install dependencies first (better Docker layer caching)
COPY backend/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy backend code
COPY backend/ ./backend/

# Copy frontend code
COPY frontend/ ./frontend/

# Create necessary directories
RUN mkdir -p /app/backend/uploads

# Expose port
EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/api/health')" || exit 1

# Run the application
CMD ["uvicorn", "backend.main:app", "--host", "0.0.0.0", "--port", "8000"]
