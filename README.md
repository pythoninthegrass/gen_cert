# gen_cert

More elaborate version of the `gen_cert` [gist](https://gist.github.com/pythoninthegrass/115f0ccb8eca51d1e422dcb097cbd088)

## Minimum Requirements
* python 3.11+
* [nginx](https://nginx.org/en/download.html)

<!-- TODO: add nginx instructions -->
## Setup
* Fill out `.env` from `.env.example`
    ```bash
    cp .env.example .env
    ```
* Create a virtual environment
    ```bash
    # virtual environment
    python3 -m venv .venv
    source .venv/bin/activate
    pip install -r requirements.txt
    ```
* Run the script
    ```bash
    python3 gen_cert.py
    ```
