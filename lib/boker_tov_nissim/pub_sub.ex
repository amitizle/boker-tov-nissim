defmodule BokerTovNissim.PubSub do

  # Subscribe to a message topic, i.e. :command or :text
  defmacro subscribe_to(topic) do
    quote do
      # TODO use config
      # message_topic = Map.fetch!(Application.fetch_env!(:boker_tov_nissim, :subscription_topics), unquote(topic))
      message_topic = BokerTovNissim.Config.get([:subscription_topics, unquote(topic)])
      :gproc.reg({:p, :l, message_topic})
    end
  end

  defmacro publish_to(topic, message) do
    quote do
      message_topic = BokerTovNissim.Config.get([:subscription_topics, unquote(topic)])
      :gproc.send({:p, :l, message_topic}, {:message, unquote(message)})
    end
  end

end
