#!/usr/bin/env python

import json
from openai import OpenAI

client = OpenAI(base_url="http://localhost:8080/v1", api_key="")

SYSTEM_PROMPT = "You are a helpful assistant."

USER_PROMPTS = [
    "Please introduce yourself.",
    "Please explain the theory of relativity.",
    "More details, please.",
    "Can you provide an example?",
    "Summarize everything you've said so far.",
    "I think there is a mistake in your explanation. Can you correct it?",
    "What are the implications of this theory in modern physics?",
    "How does this theory relate to quantum mechanics?",
    "Can you recommend some books or papers on this topic?",
    "What are some common misconceptions about the theory of relativity?",
    "How has this theory evolved since Einstein proposed it?",
    "Can you compare the theory of relativity with Newtonian mechanics?",
    "Can you explain the mathematical foundations of the theory using equations?",
    "Thank you for the information. Goodbye!",
]

messages = [{"role": "system", "content": SYSTEM_PROMPT}]

for user_prompt in USER_PROMPTS:
    messages.append({"role": "user", "content": user_prompt})
    response = client.chat.completions.create(messages=messages, model="")
    messages.append(response.choices[0].message.model_dump())

print(json.dumps(messages, indent=2))
