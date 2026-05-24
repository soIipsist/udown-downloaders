get_json_value() {

  key="$1"
  shift 1
  json_file="$1"
  shift 1
  default_value="$@"

  if [ ! -f "$json_file" ]; then
    echo "Error: JSON file does not exist or is not readable."
    return 1
  fi

  value=$(jq -r .$key "$json_file")

  if [ "$?" -ne 0 ] || [ "$value" = "null" ]; then
    value="$default_value"
  elif [[ "$value" == \[* ]]; then
    value=$(jq -r .$key[] "$json_file")
  fi

  echo "$value"
}

define_downloaders(){

    if ! command -v udown &>/dev/null; then
        echo "udown is required but not installed."
        return
    fi

    for path in *.json; do
        downloader_type=$(get_json_value "udown.downloader_type" "$path" "$(basename $path)")
        module=$(get_json_value "udown.module" "$path")
        downloader_func=$(get_json_value "udown.downloader_func" "$path")
        downloader_args=$(get_json_value "udown.downloader_args" "$path")
        
        udown downloaders add -t "$downloader_type" -m "$module" -f "$downloader_func" -args "$downloader_args" --downloader_path "$path"
    done 
}

define_downloaders
