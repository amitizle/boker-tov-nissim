defmodule BokerTovNissim.Config do

  # TODO implement get! that will raise an error

  def get(key) when is_atom(key) do
    get([key])
  end

  def get(keys) do
    get(keys, nil)
  end

  def get(key, default) when is_atom(key) do
    get([key], default)
  end

  def get(keys, default) do
    app_config = Application.get_all_env(:boker_tov_nissim)
    get_sub_key(app_config, keys, default)
  end

  def get_app_version do
    {:ok, vsn} = :application.get_key(:boker_tov_nissim, :vsn)
    vsn
  end

  defp get_sub_key({:system, env_var_name}, [], _default) do
    System.get_env(env_var_name)
  end

  defp get_sub_key(nil, [], default) do
    default
  end

  defp get_sub_key(config, [], _default) do
    config
  end

  defp get_sub_key(config, [key | rest], default) do
    get_sub_key(config[key], rest, default)
  end

end
