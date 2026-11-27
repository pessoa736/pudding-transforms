# pudding-transforms

> **Status: discontinued.** Last commit: April 2025. I'm keeping it public as a record of what I built and learned, not as a library to depend on.

An attempt to build my own AI library from scratch in pure Lua: matrices, a small neural network with backpropagation, model saving, and a tokenizer. I've been interested in artificial intelligence for a long time, and I wanted to understand how these pieces work by writing them instead of calling a framework.

## Honest notes before you read the code

- **It is not a Transformer.** The name was an aspiration. There is no attention, no embeddings, no positional encoding. What actually exists is a plain feed-forward neural network (multilayer perceptron) with sigmoid activations, trained by backpropagation.
- **It was largely "vibe coded" with GPT-4.** I did not design every part myself, and some of the code reflects that (see [Known limitations](#known-limitations)). It was still a very useful learning project: reading, running, breaking and fixing code I didn't fully understand yet is how a lot of the concepts below became clear to me.

## What's inside

```
src/                     the library (the part that matters)
  Main.lua               loads the modules according to config.lua
  Matriz.lua             Matrix class with operator overloading (metatables)
  neural_network.lua     MLP: forward pass, backpropagation, save to a Lua file
  training.lua           train(): loop of think() + backpropagation()
  Tokenizer.lua          accent normalization + word splitting
  config.default.lua     debug / test flags
  models/                saved models (plain Lua tables)
  dockerfile, docker-compose.yaml

backup/                  the web interface and the original layout, set aside
                         on 2025-04-12 to focus on the core in src/
  App/                   small web app (Lapis/OpenResty + etlua, Docker)
  README.md              the original README (Portuguese)
  LICENSE
```

### `Matriz.lua`
A `Matrix` class: `Matrix.new(rows, cols, initial)` (a number or a function `(i, j) -> value`), `+`, `-`, `*` (matrix product and scalar), `//`, unary `-`, `==`, `transpose`, `get`/`set`, `modify`, and `tostring`.

### `neural_network.lua`
`criar_rede_neural({2, 3, 1})` builds a network from a list of layer sizes. Methods: `inputsset`, `think` (forward pass), `backpropagation` (one gradient step with `target` and `learning_rate`), and `save(name)`, which serializes the model as a Lua table into `models/<name>.lua`.

### `Tokenizer.lua`
Replaces accented/special characters with their plain letters and splits a sentence into a table of words (`{[0]="isso", [1]="e", ...}`).

### `backup/App`
A small Lapis web app with a home page and a "model visualizer" route. The `/model` endpoint returns the layer sizes of a network as JSON; the visualizer page itself was never finished.

## Running it

Requires Lua 5.4. From `src/`:

```sh
lua Main.lua    # flags (DEBUGMODE, TOKENIZERTEST, ...) live in config.lua
```

The `config.lua` in the repo has `TOKENIZERTEST=true`, so this prints the tokenizer demo. (`config.default.lua` is the template the dockerfile copies into place; it has the tests turned off.) A `dockerfile` and `docker-compose.yaml` are included but I did not re-test them when writing this README.

A minimal example (run from `src/`) that teaches a small network to output ~1 for the input `{2, 3}`:

```lua
DEBUGMODE = false
dofile("Matriz.lua")
dofile("neural_network.lua")

local nn = criar_rede_neural({2, 2, 1})
nn:inputsset({{2, 3}})                 -- inputs are a 1 x N matrix
local target = Matrix.new(1, 1, 1)     -- desired output: 1

for _ = 1, 3000 do
  nn:think()
  nn:backpropagation({ target = target, learning_rate = 0.1 })
end

nn:think()
print(nn.layers[3].data[1][1])         --> about 0.95 in my run (random init, so it varies)
```

## Known limitations

These are things I verified by running the code:

- **`think()` returns `nil`.** The output has to be read from the last layer (`nn.layers[#nn.layers]`).
- **The bias is random noise, not a learned parameter.** Every forward pass adds a new random value in `[0, 0.2]`, so the same weights give slightly different outputs on each call. Only the weights are trained.
- **Everything is sigmoid, including the output layer**, and training is one sample at a time (no batches, no optimizer). It is also slow, since it uses plain Lua tables.
- **The example in `training.lua` trains on nothing useful.** It never sets inputs or a target, so it fits all-zero input to an all-zero output. The flag is also misspelled `TRAINIGTEST` and is missing from `config.default.lua`. `models/test_training.lua` is the output of that run.
- **The tokenizer is not connected to the network.** It produces a table of words, with no vocabulary, numeric IDs or embeddings. It also builds a Lua string and runs it with `load()`, so it fails on punctuation (a comma breaks it) and would be unsafe with untrusted input.
- **`backup/App/logs/` was committed by accident** (nginx access/error logs). They only contain local Docker addresses, but they don't belong in the repo.

## What this project touched

Matrices and operator overloading with metatables; the forward and backward pass of a neural network and the chain rule behind it; sigmoid and its derivative; saving a model as a Lua table; the tokenization problem (and why splitting on spaces is not enough); and a bit of Docker, OpenResty and Lapis around it.

## License

MIT, Copyright (c) 2025 Davi dos Santos Passos. See [`backup/LICENSE`](backup/LICENSE).
