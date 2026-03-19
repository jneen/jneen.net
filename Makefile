DEPLOY_PATH ?= sites/jneen.ca/

.PHONY: deploy
deploy:
	bundle exec middleman build --verbose
	rsync -P --delete --recursive ./build $$SERVER:$(DEPLOY_PATH)
	

.PHONY: dev
dev:
	bundle exec middleman --verbose
