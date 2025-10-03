#!/bin/bash

# MOSIP ID Authentication Setup Script

set -e

echo "🚀 MOSIP ID Authentication Setup"

# Check OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macOS"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="Linux"
else
    OS="Unknown"
fi

echo "Detected OS: $OS"

# Install dependencies
install_dependencies() {
    echo "📦 Installing dependencies..."
    
    if [[ "$OS" == "macOS" ]]; then
        # macOS with Homebrew
        if ! command -v brew &> /dev/null; then
            echo "Installing Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        fi
        
        echo "Installing Java 11..."
        brew install openjdk@11
        
        echo "Installing Maven..."
        brew install maven
        
        echo "Installing Docker..."
        brew install --cask docker
        
    elif [[ "$OS" == "Linux" ]]; then
        # Linux
        echo "Updating package manager..."
        sudo apt-get update
        
        echo "Installing Java 11..."
        sudo apt-get install -y openjdk-11-jdk
        
        echo "Installing Maven..."
        sudo apt-get install -y maven
        
        echo "Installing Docker..."
        sudo apt-get install -y docker.io docker-compose
        sudo systemctl start docker
        sudo systemctl enable docker
        sudo usermod -aG docker $USER
        
    else
        echo "❌ Unsupported OS. Please install manually:"
        echo "- Java 11"
        echo "- Maven"
        echo "- Docker"
        exit 1
    fi
}

# Check if tools are installed
check_tools() {
    echo "🔍 Checking installed tools..."
    
    tools=("java" "mvn" "docker")
    missing_tools=()
    
    for tool in "${tools[@]}"; do
        if command -v $tool &> /dev/null; then
            version=$($tool --version 2>&1 | head -n1)
            echo "✅ $tool: $version"
        else
            echo "❌ $tool: Not found"
            missing_tools+=($tool)
        fi
    done
    
    if [ ${#missing_tools[@]} -eq 0 ]; then
        echo "✅ All tools are installed!"
        return 0
    else
        echo "❌ Missing tools: ${missing_tools[*]}"
        return 1
    fi
}

# Main setup
case ${1:-"check"} in
    "install")
        install_dependencies
        echo "✅ Installation completed!"
        echo "⚠️  Please restart your terminal or run: source ~/.bashrc"
        ;;
    "check")
        if check_tools; then
            echo ""
            echo "🎉 Ready to build! Run:"
            echo "  ./deploy.sh dev build"
        else
            echo ""
            echo "🔧 To install missing tools, run:"
            echo "  ./setup.sh install"
        fi
        ;;
    *)
        echo "Usage: $0 [install|check]"
        echo "  install - Install all dependencies"
        echo "  check   - Check if dependencies are installed"
        ;;
esac