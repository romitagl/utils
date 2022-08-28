#!/bin/bash

# exits as soon as script fails
set -o errexit
set -o nounset
set -o pipefail

# validate env
if [[ -z "$OPENAI_API_KEY" ]]; then printf "missing required OPENAI_API_KEY env variable\n" && exit 1; fi

# validate input parameters
if [ $# -lt 1 ]; then
  printf "error: missing code input file path!"
  exit 1
else
  printf "processing: %s\n" "$1"
fi

CODE_TO_UNDERSTAND_RAW=$( cat "$1" )
# CODE_TO_UNDERSTAND="${CODE_TO_UNDERSTAND_RAW}\n\n\"\"\"\nHeres what the above code is doing:\n1."
CODE_TO_UNDERSTAND="The following piece of code executes:\n1.\n${CODE_TO_UNDERSTAND_RAW}\n\n\"\"\"\n"
MODEL_ID=${2:-"text-davinci-002"}

# printf "Code to understand:\n%s\n" "$CODE_TO_UNDERSTAND"

# Build json string to send
JSON_STRING=$(jq -n \
                  --arg prompt "$CODE_TO_UNDERSTAND" \
                  --arg model "$MODEL_ID" \
                  '{
                    "model": $model,
                    "prompt": $prompt,
                    "temperature": 0,
                    "max_tokens": 200,
                    "top_p": 1.0,
                    "frequency_penalty": 0.0,
                    "presence_penalty": 0.0,
                    "stop": ["\"\"\""]
                  }'
              )

# printf "Code to understand JSON:\n%s\n" "$JSON_STRING"

EXPLAINED_CODE_RES=$(curl -H "Content-Type: application/json" -H "Authorization: Bearer ${OPENAI_API_KEY}" https://api.openai.com/v1/completions --data "$JSON_STRING")
printf "Explained code res: %s\n" "$EXPLAINED_CODE_RES"

# {"id":"cmpl-5jxZXkArElAVuS6fiqzrpn4GnnhXk","object":"text_completion","created":1661635439,"model":"text-davinci-002","choices":[{"text":" It creates a directory for the log file if it doesnt exist\\n2. It opens the log file in append mode\\n3. It checks if the log file is newline terminated\\n4. It initializes the state of the log file\\n5. It logs an event to the log file\\","index":0,"logprobs":null,"finish_reason":"length"}],"usage":{"prompt_tokens":316,"completion_tokens":64,"total_tokens":380}}

EXPLAINED_CODE=$( echo "$EXPLAINED_CODE_RES" | jq .choices[0].text | tr -d '"' )

if [[ -z "$EXPLAINED_CODE" ]]; then
  printf "error: empty explain code response found [%s]!" "$EXPLAINED_CODE_RES"
  exit 1;
fi

SUMMARIZE_TEXT="Summarize this for a second-grade student:\n\n${EXPLAINED_CODE}"

# Build json string to send
JSON_STRING=$(jq -n \
                  --arg prompt "$SUMMARIZE_TEXT" \
                  --arg model "$MODEL_ID" \
                  '{
                    "model": $model,
                    "prompt": $prompt,
                    "temperature": 0.7,
                    "max_tokens": 50,
                    "top_p": 1.0,
                    "frequency_penalty": 0.0,
                    "presence_penalty": 0.0,
                  }'
              )


SUMMARIZE_RES=$(curl -H "Content-Type: application/json" -H "Authorization: Bearer ${OPENAI_API_KEY}" https://api.openai.com/v1/completions --data "$JSON_STRING")

# {"id":"cmpl-5jxeU6o6i41Q3w2hUicHeeMgooj3p","object":"text_completion","created":1661635746,"model":"text-davinci-002","choices":[{"text":"n\n\n1. It creates a directory for the log file if it doesn't exist.\n","index":0,"logprobs":null,"finish_reason":"length"}],"usage":{"prompt_tokens":78,"completion_tokens":20,"total_tokens":98}}

SUMMARIZE_CODE=$( echo "$SUMMARIZE_RES" | jq .choices[0].text | tr -d '"' )

if [[ -z "$SUMMARIZE_CODE" ]]; then
  printf "error: empty summarize code response found [%s]!" "$SUMMARIZE_RES"
  exit 1;
fi

printf "code explained and summarized:\n%s\n" "$SUMMARIZE_CODE"
