eb-deploy:
	rsync -av --partial --progress --exclude .git source/_build/html/ /var/www/html/nif-toolbar/

sphinx-build:
	cd source; sphinx-build -b html -d _build/doctrees . _build/html

sphinx-serve:
	cd source/_build/html; python3 -m http.server
