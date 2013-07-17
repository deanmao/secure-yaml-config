test: test-unit

test-unit:
	@NODE_ENV=test ./node_modules/.bin/mocha \
		--compilers coffee:coffee-script \
		--reporter dot \
		--require coffee-script \
		--require test/shared.coffee \
		-t 80000 \
		--colors
