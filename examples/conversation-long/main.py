#!/usr/bin/env python

import json
from openai import OpenAI

client = OpenAI(base_url="http://localhost:8080/v1", api_key="")

SYSTEM_PROMPT = "You are a helpful assistant."

USER_PROMPTS = [
    "Please introduce yourself.",
    "Please explain the theory of relativity.",
    "Can you provide an example?",
    "I think there is a mistake in your explanation. Can you correct it?",
    "What are the implications of this theory in modern physics?",
    "How does this theory relate to quantum mechanics?",
    "Can you recommend some books or papers on this topic?",
    "Can you explain the mathematical foundations of the theory using equations?",
    "Summarize everything you've said so far.",
    "Thank you for the information. Goodbye!",
]

messages = [{"role": "system", "content": SYSTEM_PROMPT}]

for user_prompt in USER_PROMPTS:
    messages.append({"role": "user", "content": user_prompt})
    response = client.chat.completions.create(messages=messages, model="")
    messages.append(response.choices[0].message.model_dump())

print(json.dumps(messages, indent=2))
