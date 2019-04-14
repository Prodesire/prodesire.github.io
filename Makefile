# Func
.PHONY: docs

help:
	@echo "\033[32minit\033[0m"
	@echo "    Init environment."
	@echo "\033[32mrun\033[0m"
	@echo "    Run server."

init:
	npm install cnpm -g
	cnpm install hexo-cli -g
	cnpm install

run:
	hexo server

new:
	hexo new $(filter-out $@,$(MAKECMDGOALS))
