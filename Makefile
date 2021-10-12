.PHONY: run
run:
	bundle exec jekyll serve

.PHONY: run-watch
run-watch:
	bundle exec jekyll serve --livereload
