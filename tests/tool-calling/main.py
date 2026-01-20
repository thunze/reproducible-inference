#!/usr/bin/env python

from datetime import datetime

from langchain.agents import create_agent
from langchain_core.tools import tool
from langchain_openai import ChatOpenAI


@tool
def get_datetime() -> str:
    """Get the current time."""
    return datetime.now().isoformat()


@tool
def get_weather(location: str) -> str:
    """Get the current weather in a given location.
    
    Args:
        location: The location to get the weather for.
    """
    if location.lower() == "san francisco":
        return "Sunny, 72F"
    elif location.lower() == "new york":
        return "Cloudy, 60F"
    else:
        return "Rainy, 55F"


model = ChatOpenAI(base_url="http://localhost:8080/v1", api_key="")

agent = create_agent(
    model,
    tools=[get_datetime, get_weather],
    system_prompt="You are a helpful assistant that can use tools to answer questions.",
)

initial_input = {"messages": [{"role": "user", "content": "What time is it?"}]}


stream = agent.stream(initial_input, stream_mode="values")
next_batch_start = -1  # Start from the last message to skip previous invocations

for event in stream:
    messages = event["messages"]

    for message in messages[next_batch_start:]:
        print()
        message.pretty_print()

    next_batch_start = len(messages)
