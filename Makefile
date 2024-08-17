.PHONY: deploy
deploy:
	bundle exec middleman build --verbose
	rsync -P --delete --recursive ./build $$SERVER:src/jneen.net/
	

.PHONY: dev
dev:
	bundle exec middleman --verbose
