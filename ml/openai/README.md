# OpenAI

The scripts included in this folder use the OpenAI `text-davinci-002` model to explain the code passed as input parameter.

Reference at: <https://beta.openai.com/docs/api-reference/completions/create>.

Example:

```bash
# download source code to process
curl -LO https://raw.githubusercontent.com/romitagl/kgraph/master/backend/hasura/auth/src/auth-service.py
# send code to OpenAI API for inference
bash get-summary-from-raw-code-simple.sh ./auth-service.py
# result:
# The code creates a new user with the username and password specified in the input. The user is given the role 'registred_user'.
```

## API KEY

API KEY available at: <https://beta.openai.com/account/api-keys>.

```bash
export OPENAI_API_KEY="your_openai_key"
```

## Models

### List models

```bash
curl -H "Authorization: Bearer $OPENAI_API_KEY" https://api.openai.com/v1/models
```

### Retrieve model

```bash
curl -H "Authorization: Bearer $OPENAI_API_KEY" https://api.openai.com/v1/models/code-davinci-edit-001
```

### Create completion

Official reference: <https://beta.openai.com/docs/api-reference/completions/create>.

```bash
curl https://api.openai.com/v1/completions \
  -H 'Content-Type: application/json' \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -d '{
  "model": "text-davinci-002",
  "prompt": "Say this is a test",
  "max_tokens": 6,
  "temperature": 0
}'
```

## Explain code

```bash
curl https://api.openai.com/v1/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -d '{
  "model": "code-davinci-edit-001",
  "prompt": "class Log:\n    def __init__(self, path):\n        dirname = os.path.dirname(path)\n        os.makedirs(dirname, exist_ok=True)\n        f = open(path, \"a+\")\n\n        # Check that the file is newline-terminated\n        size = os.path.getsize(path)\n        if size > 0:\n            f.seek(size - 1)\n            end = f.read(1)\n            if end != \"\\n\":\n                f.write(\"\\n\")\n        self.f = f\n        self.path = path\n\n    def log(self, event):\n        event[\"_event_id\"] = str(uuid.uuid4())\n        json.dump(event, self.f)\n        self.f.write(\"\\n\")\n\n    def state(self):\n        state = {\"complete\": set(), \"last\": None}\n        for line in open(self.path):\n            event = json.loads(line)\n            if event[\"type\"] == \"submit\" and event[\"success\"]:\n                state[\"complete\"].add(event[\"id\"])\n                state[\"last\"] = event\n        return state\n\n\"\"\"\nHeres what the above class is doing:\n1.",
  "temperature": 0,
  "max_tokens": 64,
  "top_p": 1.0,
  "frequency_penalty": 0.0,
  "presence_penalty": 0.0,
  "stop": ["\"\"\""]
}'
```

## Summarize for a 2nd grader

```bash
curl https://api.openai.com/v1/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -d '{
  "model": "text-davinci-002",
  "prompt": "Summarize this for a second-grade student:\n\nJupiter is the fifth planet from the Sun and the largest in the Solar System. It is a gas giant with a mass one-thousandth that of the Sun, but two-and-a-half times that of all the other planets in the Solar System combined. Jupiter is one of the brightest objects visible to the naked eye in the night sky, and has been known to ancient civilizations since before recorded history. It is named after the Roman god Jupiter.[19] When viewed from Earth, Jupiter can be bright enough for its reflected light to cast visible shadows,[20] and is on average the third-brightest natural object in the night sky after the Moon and Venus.",
  "temperature": 0.7,
  "max_tokens": 64,
  "top_p": 1.0,
  "frequency_penalty": 0.0,
  "presence_penalty": 0.0
}'
```
