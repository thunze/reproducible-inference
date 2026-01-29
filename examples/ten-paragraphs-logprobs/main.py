#!/usr/bin/env python

import json
from openai import OpenAI

client = OpenAI(base_url="http://localhost:8080/v1", api_key="")

response = client.chat.completions.create(
    messages=[
        {
            "role": "user",
            "content": "Please write 10 paragraphs about apples.",
        },
    ],
    logprobs=5,
    model="",
)

choice = response.choices[0]
output = {
    "message": choice.message.content,
    "logprobs": choice.logprobs.model_dump(),
}
print(json.dumps(output, indent=2))
