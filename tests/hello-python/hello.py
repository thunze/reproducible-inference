#!/usr/bin/env python

from openai import OpenAI

client = OpenAI(base_url="http://localhost:8080/v1", api_key="")

response = client.chat.completions.create(
    messages=[
        {
            "role": "user",
            "content": "Hello, world!",
        },
    ],
    model="",
)

print(response.choices[0].message.content)
