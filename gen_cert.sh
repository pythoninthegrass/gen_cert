#!/usr/bin/env bash

# shellcheck disable=SC2162

# certbot location
UNAME=$(uname -s)
if [ "$UNAME" = "Darwin" ]; then
	BREW_PREFIX=$(brew --prefix)
	PATH="$BREW_PREFIX/bin:/usr/local/bin:$PATH"
elif [ "$UNAME" = "Linux" ]; then
	PATH="/usr/bin:/bin:$PATH"
fi

# verify certbot is installed
if ! command -v certbot &> /dev/null; then
	echo "certbot is not installed"
	exit 1
fi

# read env vars
ENV_VARS=$(env | grep -E 'ACME_URI|EMAIL|WEBROOT|NAKED_DOMAIN|WWW_DOMAIN')
if [ -n "$ENV_VARS" ]; then
	export $(echo "$ENV_VARS" | xargs)
fi

# get the root directory
GIT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)"
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
if [ -n "$GIT_ROOT" ]; then
	TLD="$GIT_ROOT"
else
	TLD="${SCRIPT_DIR}"
fi
ENV_FILE="${TLD}/.env"

# source .env file skipping commented lines
if [ -f "${ENV_FILE}" ]; then
	export $(grep -v '^#' ${ENV_FILE} | xargs)
fi

help() {
	echo "USAGE"
	echo -e "\t$(basename $0)\t<options>"
	echo -e "OPTIONS"
	echo -e "\t-s\t--server <server>\tACME server (prod|dev)"
	echo -e "\t-e\t--email <email>\t\tEmail"
	echo -e "\t-w\t--webroot <webroot>\tWebroot path"
	echo -e "\t-d\t--domain <domain>\tNaked domain (example.com)"
	echo -e "\t-h\t--help\t\t\tDisplay this help and exit"
}

# acme server
ACME_DEV_URL="https://acme-staging-v02.api.letsencrypt.org/directory"	# dev
ACME_PROD_URL="https://acme-v02.api.letsencrypt.org/directory"         	# prod

# parse options
if [[ $# -gt 0 ]]; then
	case "$1" in
		-s|--server)
			if [ "$2" = "dev" ]; then
				ACME_URI=$ACME_DEV_URL
			else
				ACME_URI=$ACME_PROD_URL
			fi
			shift 2
			;;
		-e|--email)
			read -p "Enter your email: " EMAIL
			shift 2
			;;
		-w|--webroot)
			read -p "Enter the webroot path: " WEBROOT
			shift 2
			;;
		-d|--domain)
			read -p "Enter the naked domain: " NAKED_DOMAIN
			WWW_DOMAIN="www.$NAKED_DOMAIN"
			shift 2
			;;
		-h|--help)
			help
			exit 0
			;;
		*)
			echo "Invalid option"
			shift
			;;
	esac
fi

check_options() {
	[[ -z $ACME_URI ]] && ACME_URI=$ACME_DEV_URL
	[[ -z $EMAIL ]] && read -p "Enter your email: " EMAIL
	[[ -z $WEBROOT ]] && read -p "Enter the webroot path: " WEBROOT
	[[ -z $NAKED_DOMAIN ]] && read -p "Enter the naked domain: " NAKED_DOMAIN
	[[ -z $WWW_DOMAIN ]] && WWW_DOMAIN="www.$NAKED_DOMAIN"
}

gen_cert() {
	certbot certonly -v \
        --logs-dir ./logs \
		--expand \
		--server $ACME_URI \
		--agree-tos \
		--email $EMAIL \
		-w $WEBROOT \
		-d $NAKED_DOMAIN \
		-d $WWW_DOMAIN
}

main() {
	check_options
	gen_cert
}
main "$@"

exit 0
