LONGOPTS="help,location:,server-type:,ssh-key:,save-config-to"
OPTIONS="hl:t:s:o"
PARSED=$(getopt --options=$OPTIONS --longoptions=$LONGOPTS --name "$0" -- "$@") || exit 2
eval set -- "$PARSED"
SSH_KEYS_LIST=()
SAVE_CONFIG_TO="$PWD"

while true; do
	case "$1" in
	-h | --help)
		echo 'Usage: create-hcloud-nixos-snapshot \
		--location fsn1 \
		--ssh-key "ssh-ed25519 AAAAdh3dgx82..." \
		--save-config-to ./'
		exit 3
		;;
	-l | --location)
		LOCATION="$2"
		shift 2
		;;
	-t | --server-type)
		SERVER_TYPE="$2"
		shift 2
		;;
	-s | --ssh-key)
		SSH_KEYS_LIST+=("$2")
		shift 2
		;;
	-o | --save-config-to)
		SAVE_CONFIG_TO=$(realpath "$2")
		shift 2
		;;
	--)
		shift
		break
		;;
	*)
		exit 3
		;;
	esac
done

SSH_KEYS=$(jq -c -n '$ARGS.positional' --args "${SSH_KEYS_LIST[@]}")

packer init "$PATH_ROOT"
packer build \
	-var="location=$LOCATION" \
	-var="server_type=$SERVER_TYPE" \
	-var="ssh_keys=$SSH_KEYS" \
	-var="save_config_to=$SAVE_CONFIG_TO" \
	"$PATH_ROOT"
