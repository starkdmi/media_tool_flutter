# media_tool_platform_interface

A common platform interface for the `media_tool` plugin.

This interface allows platform-specific implementations of the `media_tool` plugin, as well as the plugin itself, to ensure they are supporting the same interface.

# Usage

To implement a new platform-specific implementation of `media_tool`, extend `MediaToolPlatform` with an implementation that performs the platform-specific behavior.
