#!/bin/bash

# Simple healthcheck script for testing
check_service() {
    local url=$1
    local service_name=$2
    local max_attempts=10
    local attempt=1
    
    echo "Checking $service_name health at $url"
    
    while [ $attempt -le $max_attempts ]; do
        echo "Attempt $attempt/$max_attempts for $service_name..."
        
        if curl -f -s "$url" > /dev/null 2>&1; then
            echo "✅ $service_name is healthy!"
            return 0
        fi
        
        echo "❌ $service_name not ready yet, waiting..."
        sleep 10
        ((attempt++))
    done
    
    echo "❌ $service_name failed to become healthy after $max_attempts attempts"
    return 1
}

# Export function for use in other scripts
export -f check_service
