#!/usr/bin/env python

from datetime import datetime

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


llm = ChatOpenAI(base_url="http://localhost:8080/v1", api_key="")
llm_with_tools = llm.bind_tools([get_datetime, get_weather])

response = llm_with_tools.invoke(
    [
        (
            "system",
            "You are a helpful assistant that can use tools to answer user queries.",
        ),
        ("user", "What time is it?"),
    ],
)

print(response)
