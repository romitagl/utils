#!/bin/bash

# exits as soon as script fails
set -e

# validate env
if [[ -z "$OPENAI_API_KEY" ]]; then printf "missing required OPENAI_API_KEY env variable\n" && exit 1; fi


TEXT="Summarize this for a second-grade student:\n\n It creates a directory for the log file if it doesnt exist\\n2. It opens the log file in append mode\\n3. It checks if the log file is newline terminated\\n4. It initializes the state of the log file\\n5. It logs an event to the log file\\"

# Build json string to send
JSON_STRING=$(jq -n \
                  --arg prompt "$TEXT" \
                  '{
                    "model": "text-davinci-002",
                    "prompt": $prompt,
                    "temperature": 0.7,
                    "max_tokens": 20,
                    "top_p": 1.0,
                    "frequency_penalty": 0.0,
                    "presence_penalty": 0.0,
                  }'
              )


curl -H "Content-Type: application/json" -H "Authorization: Bearer ${OPENAI_API_KEY}" https://api.openai.com/v1/completions --data "$JSON_STRING"
