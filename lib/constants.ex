defmodule Constants do
  defmacro __using__(_opts) do
    quote do
      import Constants
    end
  end

  defmacro constant(name, value) do
    quote do
      defmacro unquote(name), do: unquote(value)
    end
  end
end
