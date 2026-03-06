#!/usr/bin/env python

import json
from openai import OpenAI

client = OpenAI(base_url="http://localhost:8080/v1", api_key="")

messages = [
    {
        "role": "user",
        "content": "I was born in 1990. How old am I in 2024?",
    }
]

response = client.chat.completions.create(
    messages=messages,
    extra_body={"chat_template_kwargs": {"enable_thinking": True}},
    model="",
)
messages.append(response.choices[0].message.model_dump())

print(json.dumps(messages, indent=2))
