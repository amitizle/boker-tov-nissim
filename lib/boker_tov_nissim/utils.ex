defmodule BokerTovNissim.Utils do
  def write_temp_file(content, _opts \\ []) do
    # TODO consider opts, in the meantime it's been _'ed
    # TODO support not only bin write
    case Temp.open do
      {:ok, fd, file_path} ->
        IO.binwrite(fd, content)
        File.close(fd)
        {:ok, file_path}
      error -> {:error, error}
    end
  end

  def remove_file(file_path) do
    File.rm(file_path)
  end

  def replace_occurences(regex, str, occurences_map) do
    replace_fn = fn(_, _match) ->
      Enum.reduce(occurences_map, str, fn({reg, val}, acc) -> Regex.replace(reg, acc, val) end)
    end
    Regex.replace(regex, str, replace_fn)
  end
end
