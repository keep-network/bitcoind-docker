.PHONY: docker-build
docker-build: ## Build Docker image
	@direnv reload
	@printf "Current VERSION: %s\n" "$$VERSION"
	@read -p "Have you updated the VERSION file? (y/N): " res && [[ $$res == [yY] ]] || exit 1
	docker build --platform linux/amd64 --build-arg BITCOIN_CORE_VERSION=$(VERSION) --tag $(DOCKER_IMAGE_NAME):$(VERSION) .

.PHONY: docker-push
docker-push: ## Push Docker image to registry
	@direnv reload
	docker push $(DOCKER_IMAGE_NAME):$(VERSION)

