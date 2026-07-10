FROM golang:1.23-alpine AS builder

WORKDIR /app

# Install dependencies
COPY go.mod go.sum ./
RUN go mod download

# Copy source code
COPY . .

# Build the application
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o server ./cmd/server/main.go

FROM alpine:latest

WORKDIR /app

# Copy the binary from builder
COPY --from=builder /app/server .
# Copy Swagger docs
COPY --from=builder /app/docs /app/docs

# Expose port
EXPOSE 8080

# Command to run the executable
CMD ["./server"]
