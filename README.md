![2026-03-02 18 00 19](https://github.com/user-attachments/assets/c845a518-641c-4240-abd9-a3b8c617d808)

## What is this?

This is a simple program that puts a dot in the MacOS menu bar when running `status-dot show` in a command line.

I did this so I could have an easy way to see if claude code needed attention but wasn't as distracting as a noise or system notification. 

The available commands:

`status-dot show`: Show the dot

`status-dot hide`: Hide the dot

`status-dot toggle`: Flip the state of the dot

`status-dot quit`: Quit the application

I added the following snippet to my `~/.claude/settings.json` to toggle the dot. I had to call `hide` in a lot of places so that the dot would be gone when I wanted it to be. Still doing some optimizations here.
```
"hooks": {
    "Notification": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "status-dot show"
          }
        ]
      }
    ],
    "UserPromptSubmit": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "status-dot hide"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "status-dot hide"
          }
        ]
      }
    ],
    "PostToolUseFailure": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "status-dot hide"
          }
        ]
      }
    ],
    "SessionEnd": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "status-dot hide"
          }
        ]
      }
    ]
  },

```
