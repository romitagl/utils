#!/bin/bash

# exits as soon as script fails
set -e

# validate env
if [[ -z "$OPENAI_API_KEY" ]]; then printf "missing required OPENAI_API_KEY env variable\n" && exit 1; fi


TEXT="class Log:\n    def __init__(self, path):\n        dirname = os.path.dirname(path)\n        os.makedirs(dirname, exist_ok=True)\n        f = open(path, \"a+\")\n\n        # Check that the file is newline-terminated\n        size = os.path.getsize(path)\n        if size > 0:\n            f.seek(size - 1)\n            end = f.read(1)\n            if end != \"\\n\":\n                f.write(\"\\n\")\n        self.f = f\n        self.path = path\n\n    def log(self, event):\n        event[\"_event_id\"] = str(uuid.uuid4())\n        json.dump(event, self.f)\n        self.f.write(\"\\n\")\n\n    def state(self):\n        state = {\"complete\": set(), \"last\": None}\n        for line in open(self.path):\n            event = json.loads(line)\n            if event[\"type\"] == \"submit\" and event[\"success\"]:\n                state[\"complete\"].add(event[\"id\"])\n                state[\"last\"] = event\n        return state\n\n\"\"\"\nHeres what the above class is doing:\n1."

# Build json string to send
JSON_STRING=$(jq -n \
                  --arg prompt "$TEXT" \
                  '{
                    "model": "text-davinci-002",
                    "prompt": $prompt,
                    "temperature": 0,
                    "max_tokens": 64,
                    "top_p": 1.0,
                    "frequency_penalty": 0.0,
                    "presence_penalty": 0.0,
                    "stop": ["\"\"\""]
                  }'
              )


curl -H "Content-Type: application/json" -H "Authorization: Bearer ${OPENAI_API_KEY}" https://api.openai.com/v1/completions --data "$JSON_STRING"
