# nvim-llama

Code explainer using local models via ollama

UNDER

     CONST

          RUCTIO

                N

## Requirements

- curl
- ollama

ollama: [download](https://ollama.com/download)

The default model is llame3:latest. You need to pull it before using this plugin.
(requires ollama-cli also)

```bash
ollama pull llame3:latest
```

## Installation

```lua
require('lazy').setup({
    ..., -- other plugins
    {
        'sagmansercan/nvim-llama',
        event = 'VeryLazy',
        opts = {},
    },
})
```
