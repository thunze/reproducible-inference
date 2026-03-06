#!/usr/bin/env python

import json
from httpx import Timeout
from openai import OpenAI

client = OpenAI(
    base_url="http://localhost:8080/v1",
    api_key="",
    # Set a longer timeout for slow hardware as this is a rather large generation.
    timeout=Timeout(timeout=3600, connect=5.0),
)

response = client.chat.completions.create(
    messages=[
        {
            "role": "user",
            "content": "Please write 10 paragraphs about apples.",
        },
    ],
    # llama.cpp supports setting `logprobs` to an integer to get logprobs for the
    # top N tokens. OpenAI's API officially only supports a boolean here, so passing
    # a number will print a (harmless) warning.
    logprobs=5,
    extra_body={"chat_template_kwargs": {"enable_thinking": False}},
    model="",
)

choice = response.choices[0]
output = {
    "message": choice.message.content,
    "logprobs": choice.logprobs.model_dump(),
}
print(json.dumps(output, indent=2))
