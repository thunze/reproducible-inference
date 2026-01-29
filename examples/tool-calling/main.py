#!/usr/bin/env python

from itertools import count

from langchain.messages import HumanMessage, SystemMessage
from langchain_core.tools import tool
from langchain_openai import ChatOpenAI


@tool
def get_datetime() -> str:
    """Get the current time."""
    # We can't return the actual current time here because that would make the test
    # non-deterministic.
    return "2026-01-27T14:32:33.990923"


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


TOOLS_BY_NAME = {
    "get_datetime": get_datetime,
    "get_weather": get_weather,
}


def main():
    llm = ChatOpenAI(base_url="http://localhost:8080/v1", api_key="")
    llm_with_tools = llm.bind_tools([get_datetime, get_weather])

    messages = []
    tool_call_id_counter = count()

    # System message
    system_message = SystemMessage(
        "You are a helpful assistant. You can use tools to get the current time and "
        "weather information. Once you have the information, provide an answer to "
        "user."
    )
    system_message.pretty_print()
    messages.append(system_message)

    ## Time query

    # User asks for time
    human_message_time = HumanMessage("What time is it?")
    human_message_time.pretty_print()
    messages.append(human_message_time)

    # AI responds with tool call
    ai_message_time = llm_with_tools.invoke(messages)
    # Replace random tool call IDs with deterministic ones for reproducibility
    ai_message_time.tool_calls = [
        call | {"id": str(next(tool_call_id_counter))}
        for call in ai_message_time.tool_calls
    ]
    ai_message_time.pretty_print()
    messages.append(ai_message_time)

    # We invoke the tools that were called
    for tool_call in ai_message_time.tool_calls:
        tool = TOOLS_BY_NAME[tool_call["name"]]
        tool_message = tool.invoke(tool_call)
        tool_message.pretty_print()
        messages.append(tool_message)

    # AI provides final answer
    ai_message_time_final = llm.invoke(messages)
    ai_message_time_final.pretty_print()
    messages.append(ai_message_time_final)

    ## Weather query

    # User asks for weather
    human_message_weather = HumanMessage("What's the weather in San Francisco?")
    human_message_weather.pretty_print()
    messages.append(human_message_weather)

    # AI responds with tool call
    ai_message_weather = llm_with_tools.invoke(messages)
    # Replace random tool call IDs with deterministic ones for reproducibility
    ai_message_weather.tool_calls = [
        call | {"id": str(next(tool_call_id_counter))}
        for call in ai_message_weather.tool_calls
    ]
    ai_message_weather.pretty_print()
    messages.append(ai_message_weather)
    
    # We invoke the tools that were called
    for tool_call in ai_message_weather.tool_calls:
        tool = TOOLS_BY_NAME[tool_call["name"]]
        tool_message = tool.invoke(tool_call)
        tool_message.pretty_print()
        messages.append(tool_message)

    # AI provides final answer
    ai_message_weather_final = llm.invoke(messages)
    ai_message_weather_final.pretty_print()
    messages.append(ai_message_weather_final)


if __name__ == "__main__":
    main()
