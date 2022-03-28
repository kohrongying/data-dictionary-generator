setup:
	docker-compose up -d && sleep 30

run: setup
	./run.sh 

node: run
	docker build -t dd . && docker run --rm -v $(shell pwd):/app dd

down: node
	docker-compose down && rm -rf output && rm tables.log

cleanup:
	docker-compose down && rm -rf output && rm tables.log

pdf: down