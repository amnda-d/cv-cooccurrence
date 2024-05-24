.PHONY: clean build lint test help figures

clean:
	@find . -name '*.pyc' -exec rm -f {} +
	@find . -name '*.pyo' -exec rm -f {} +
	@find . -name '*~' -exec rm -f  {} +
	@find . -name '__pycache__' -exec rm -rf {} +

lint:
	pylint --rcfile="pylintrc" src
	pylint --rcfile="pylintrc" tests --disable=import-error

test:
	nose2 -c tests/nose2.cfg -v --layer-reporter
	@make clean

testall: lint test

run:
	mkdir -p data
	mkdir -p data/lex_data
	mkdir -p data/r_data
	python -m src

download_panphon:
	curl https://raw.githubusercontent.com/dmort27/panphon/3adf14eff913e87386f4ec859deece44e318e116/panphon/data/ipa_all.csv > src/feats/panphon.csv

download_northeuralex:
	mkdir -p data
	mkdir -p data/northeuralex
	curl http://www.sfs.uni-tuebingen.de/\~jdellert/northeuralex/0.9/northeuralex-0.9-forms.tsv > data/northeuralex/northeuralex-0.9-forms.tsv
	curl http://www.sfs.uni-tuebingen.de/\~jdellert/northeuralex/0.9/northeuralex-0.9-language-data.tsv > data/northeuralex/northeuralex-0.9-language-data.tsv

run_nc_model:
	Rscript models/final_model/script.R nat_class_sim final_model

run_feat_model:
	Rscript models/final_model/script.R sim final_model

figures:
	mkdir -p figures
	Rscript figures.R

help:
	@echo "  clean"
	@echo "    Remove python artifacts."
	@echo "  lint"
	@echo "    Check style with pylint."
	@echo "  test"
	@echo "    Run nose2 tests."
	@echo "  testall"
	@echo "    Lint, typecheck, and run tests"
	@echo "  run"
	@echo "    Generate the dataset for northeuralex"
	@echo "  download_panphon"
	@echo "    Download panphon features from https://github.com/dmort27/panphon"
	@echo "  download_northeuralex"
	@echo "    Download NorthEuraLex files from http://northeuralex.org/"
	@echo "  figures"
	@echo "    Make plots of models"
	@echo "  run_nc_model"
	@echo "    Run the Natural Class Similarity (NC) model"
	@echo "  run_feat_model"
	@echo "    Run the Feature Similarity (Feat) model"
