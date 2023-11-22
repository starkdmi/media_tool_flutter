# media_tool_platform_interface

A common platform interface for the [media_tool_flutter](https://github.com/starkdmi/media_tool_flutter) plugin.

This interface allows platform-specific implementations of the `media_tool_flutter` plugin, as well as the plugin itself, to ensure they are supporting the same interface.

# Usage

To implement a new platform-specific implementation of `media_tool_flutter`, extend `MediaToolPlatform` with an implementation that performs the platform-specific behavior.
