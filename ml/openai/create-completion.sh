#!/bin/bash

# exits as soon as script fails
set -o errexit
set -o nounset
set -o pipefail

# validate env
if [[ -z "$OPENAI_API_KEY" ]]; then printf "missing required OPENAI_API_KEY env variable\n" && exit 1; fi

# validate input parameters
if [ $# -lt 1 ]; then
  printf "error: missing input prompt!"
  exit 1
else
  printf "processing: %s\n" "$1"
fi

COMPLETION_INPUT="$1"
MODEL_ID=${2:-"text-davinci-002"}

# Build json string to send
JSON_STRING=$(jq -n \
                  --arg prompt "$COMPLETION_INPUT" \
                  --arg model "$MODEL_ID" \
                  '{
                    "model": $model,
                    "prompt": $prompt,
                    "temperature": 0,
                    "max_tokens": 200,
                  }'
              )

COMPLETION_OUTPUT=$(curl -H "Content-Type: application/json" -H "Authorization: Bearer ${OPENAI_API_KEY}" https://api.openai.com/v1/completions --data "$JSON_STRING")
printf "Prediction: %s\n" "$COMPLETION_OUTPUT"
