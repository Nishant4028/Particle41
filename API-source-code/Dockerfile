# Use a small official Python image
FROM python:3.12-slim

# Create a working directory
WORKDIR /app

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy app files
COPY . .

# Create a non-root user
RUN useradd -m simpleuser
USER simpleuser

# Expose FastAPI default port
EXPOSE 8000

# Command to run the app
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
