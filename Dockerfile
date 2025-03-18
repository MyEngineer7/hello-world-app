# Build stage - Alpine to install dependencies
FROM python:3.11-alpine AS builder

# Create non-root user for security
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Set working directory
WORKDIR /app

# Copy requirements and install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt --target=/app/dependencies

# Copy application code
COPY app.py .

# Final stage - use distroless Python image
FROM gcr.io/distroless/python3:nonroot

# Set working directory
WORKDIR /app

# Copy dependencies and application from builder stage
COPY --from=builder /app/dependencies /app/dependencies
COPY --from=builder /app/app.py /app/

# Add dependencies to Python path
ENV PYTHONPATH=/app:/app/dependencies

# Port the application uses
EXPOSE 8000

# Command to run the application with timeout
CMD ["/app/dependencies/bin/gunicorn", "--bind", "0.0.0.0:8000", "--timeout", "1000", "app:app"] 