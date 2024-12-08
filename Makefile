FRONTEND_DIR = schrodinger-web
FRONTEND_URL = http://localhost:8080

.PHONY: install run-local run-sepolia update run-base-sepolia run-zkevm-cardona

install:
	node_version=`node -v`; \
	if ! echo $$node_version | grep -qE '^v18\.'; then \
		command -v nvm >/dev/null 2>&1 || \
			curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash && \
			. ~/.nvm/nvm.sh && \
			nvm install 18; \
		. ~/.nvm/nvm.sh && \
		nvm use 18; \
	fi
	command -v pnpm >/dev/null 2>&1 || { \
		curl -fsSL https://get.pnpm.io/v6.21.js | node - add --global pnpm \
	}

# Kill any running processes
define kill_processes
	lsof -ti :3000 | xargs kill -9 || true # kill previous instance of the backend
	lsof -ti :8545 | xargs kill -9 || true # kill previous instance of Ganache
	lsof -ti :8080 | xargs kill -9 || true # kill previous instance of the frontend
	lsof -ti :9999 | xargs kill -9 || true # kill any Next.js process
endef

# Setup and start frontend
define setup_frontend
	if [ ! -d "truthify-web" ]; then \
		git clone https://github.com/Shreya23-tech/truthify-web.git $(FRONTEND_DIR); \
	fi
	cd $(FRONTEND_DIR) && pnpm install
	cd $(FRONTEND_DIR) && NEXT_PUBLIC_PORT=8080 PORT=8080 NODE_ENV=$(1) pnpm dev --port 8080 &
	@echo "Waiting for the frontend to be up and running..."
	sleep 10
	@if command -v open >/dev/null 2>&1; then \
		open $(FRONTEND_URL); \
	elif command -v xdg-open >/dev/null 2>&1; then \
		xdg-open $(FRONTEND_URL); \
	fi
	# Keep the process running
	wait
endef

# Run locally with Ganache
run-local:
	@echo "Starting local deployment with Ganache..."
	$(call kill_processes)
	pnpm install
	export NODE_ENV=development && pnpm backend &
	@echo "Waiting for the backend to be up and running..."
	sleep 30
	$(call setup_frontend,development)

# Run with Sepolia deployment
run-sepolia:
	@echo "Starting Sepolia deployment..."
	# Check if .env exists
	@if [ ! -f ".env" ]; then \
		echo "Error: .env file not found. Please create one with MNEMONIC/PRIVATE_KEY and INFURA_PROJECT_ID"; \
		exit 1; \
	fi
	$(call kill_processes)
	pnpm install
	# Deploy to Sepolia
	@echo "Deploying smart contracts to Sepolia..."
	# Source .env file and export variables before running truffle
	@( \
		set -a; \
		. ./.env; \
		set +a; \
		NETWORK=sepolia NODE_ENV=production npx truffle migrate --network sepolia --reset --compile-none \
	)
	# Start backend in production mode
	@( \
		set -a; \
		. ./.env; \
		set +a; \
		NETWORK=sepolia NODE_ENV=production pnpm backend & \
	)
	@echo "Waiting for the backend to be up and running..."
	sleep 30
	$(call setup_frontend,production)

# Run with Base Sepolia deployment
run-base-sepolia:
	@echo "Starting Base Sepolia deployment..."
	# Check if .env exists
	@if [ ! -f ".env" ]; then \
		echo "Error: .env file not found. Please create one with MNEMONIC/PRIVATE_KEY"; \
		exit 1; \
	fi
	$(call kill_processes)
	pnpm install
	# Deploy to Base Sepolia
	@echo "Deploying smart contracts to Base Sepolia..."
	@( \
		set -a; \
		. ./.env; \
		set +a; \
		NETWORK=base-sepolia NODE_ENV=production npx truffle migrate --network base-sepolia --reset --compile-none \
	)
	# Start backend in production mode
	@( \
		set -a; \
		. ./.env; \
		set +a; \
		NETWORK=base-sepolia NODE_ENV=production pnpm backend & \
	)
	@echo "Waiting for the backend to be up and running..."
	sleep 30
	$(call setup_frontend,production)

# Run with Polygon zkEVM Cardona deployment
run-zkevm-cardona:
	@echo "Starting Polygon zkEVM Cardona deployment..."
	# Check if .env exists
	@if [ ! -f ".env" ]; then \
		echo "Error: .env file not found. Please create one with MNEMONIC/PRIVATE_KEY"; \
		exit 1; \
	fi
	$(call kill_processes)
	pnpm install
	# Deploy to Polygon zkEVM Cardona
	@echo "Deploying smart contracts to Polygon zkEVM Cardona..."
	@( \
		set -a; \
		. ./.env; \
		set +a; \
		NETWORK=zkevm-cardona NODE_ENV=production npx truffle migrate --network zkevm-cardona --reset --compile-none \
	)
	# Start backend in production mode
	@( \
		set -a; \
		. ./.env; \
		set +a; \
		NETWORK=zkevm-cardona NODE_ENV=production pnpm backend & \
	)
	@echo "Waiting for the backend to be up and running..."
	sleep 30
	$(call setup_frontend,production)

# Alias for backward compatibility
run: run-local

update:
	git pull && pnpm install
	cd $(FRONTEND_DIR) && git pull && pnpm install
	make run-local
