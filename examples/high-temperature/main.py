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
    temperature=10,
    # Disable top-p and min-p sampling to isolate the effect of high temperature.
    top_p=1.0,
    # OpenAI's API doesn't officially support the `min_p` and `chat_template_kwargs`
    # parameters, but we can still pass them in `extra_body` and the llama.cpp server
    # will use them.
    extra_body={
        "min_p": 0.0,
        "chat_template_kwargs": {"enable_thinking": False},
    },
    # Set an upper bound on the number of output tokens to prevent excessively long
    # outputs that can result from the high temperature setting.
    max_tokens=500,
    model="",
)

print(response.choices[0].message.content)
