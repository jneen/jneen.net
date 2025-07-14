.PHONY: deploy
deploy:
	bundle exec middleman build --verbose
	rsync -P --delete --recursive ./build $$SERVER:sites/jneen.ca/
	

.PHONY: dev
dev:
	bundle exec middleman --verbose
