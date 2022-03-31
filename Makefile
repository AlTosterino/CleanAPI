PROJ_PTH=$(dir $(abspath $(lastword $(MAKEFILE_LIST))))
PYTHON_EXEC?=python
APP_PATH = src/clean_api

LINT_PATHS = \
$(APP_PATH) \
tests \

init:
	pip install pip-tools
	$(MAKE) sync-deps

run:
	uvicorn clean_api.web_app.main:app --reload

lint:
	$(PYTHON_EXEC) -W ignore -m autoflake --in-place --recursive --ignore-init-module-imports --remove-duplicate-keys --remove-unused-variables --remove-all-unused-imports $(LINT_PATHS)
	$(PYTHON_EXEC) -m black $(LINT_PATHS)
	$(PYTHON_EXEC) -m isort $(LINT_PATHS)
	$(PYTHON_EXEC) -m mypy $(APP_PATH) $(LOAD_TESTS_PATH) --ignore-missing-imports

test:
	$(PYTHON_EXEC) -m pytest -n auto --cov --cov-report term:skip-covered
compile-deps:
	$(PYTHON_EXEC) -m piptools compile --no-annotate --no-header --generate-hashes "${PROJ_PTH}requirements/dev.in"
	$(PYTHON_EXEC) -m piptools compile --no-annotate --no-header --generate-hashes "${PROJ_PTH}requirements/prod.in"


recompile-deps:
	$(PYTHON_EXEC) -m piptools compile --no-annotate --no-header --generate-hashes --upgrade "${PROJ_PTH}requirements/dev.in"
	$(PYTHON_EXEC) -m piptools compile --no-annotate --no-header --generate-hashes --upgrade "${PROJ_PTH}requirements/prod.in"


sync-deps:
	$(PYTHON_EXEC) -m piptools sync "${PROJ_PTH}requirements/dev.txt"
	$(PYTHON_EXEC) -m pip install -e .


sync-deps-prod:
	$(PYTHON_EXEC) -m piptools sync "${PROJ_PTH}requirements/prod.txt"


mypy-types-update:
	mypy --install-types

lint-ci:
	$(PYTHON_EXEC) -m autoflake --check --recursive --ignore-init-module-imports --remove-duplicate-keys --remove-unused-variables --remove-all-unused-imports $(LINT_PATHS) > /dev/null
	$(PYTHON_EXEC) -m isort --check-only $(LINT_PATHS)
	$(PYTHON_EXEC) -m black --check $(LINT_PATHS)
	$(PYTHON_EXEC) -m mypy $(APP_PATH) --ignore-missing-imports

test-ci:
	$(PYTHON_EXEC) -m pytest -n auto --cov --cov-report html
