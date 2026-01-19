#!/usr/bin/env python

import json
from openai import OpenAI

client = OpenAI(base_url="http://localhost:8080/v1", api_key="")

SYSTEM_PROMPT = "You are a helpful assistant. Answer concisely."

USER_PROMPTS = [
    "Hi there! What's the capital of France?",
    "Can you tell me a joke?",
    "What's the weather like today?",
    "How do I bake a chocolate cake?",
    "What's the tallest mountain in the world?",
]

messages = [{"role": "system", "content": SYSTEM_PROMPT}]

for user_prompt in USER_PROMPTS:
    messages.append({"role": "user", "content": user_prompt})
    response = client.chat.completions.create(messages=messages, model="")
    messages.append(response.choices[0].message.model_dump())

print(json.dumps(messages, indent=2))
