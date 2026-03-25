FROM python:3.12-slim

WORKDIR /tests

# Install system dependencies for Browser Library
RUN apt-get update && apt-get install -y --no-install-recommends \
    nodejs npm \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Initialize Browser Library
RUN rfbrowser init chromium

# Copy test files
COPY . .

# Default: run non-browser tests
CMD ["robot", "--outputdir", "/results", "--exclude", "browser", "--exclude", "docker", "tests/"]
