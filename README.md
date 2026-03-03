This is a simple program that when running `status-dot show` in a command line puts a little dot in the menu bar in MacOS.

I did this so I could have an easy way to see if claude code needed attnetion but wasn't as distracting as a noise or system notification. 

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
