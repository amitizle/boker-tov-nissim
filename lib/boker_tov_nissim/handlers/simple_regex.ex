defmodule BokerTovNissim.Handlers.SimpleRegex do
  use GenServer
  require BokerTovNissim.PubSub
  alias BokerTovNissim.PubSub
  require Logger

  @server :simple_regex
  @response_probability 0.6

  # API

  def start_link do
    GenServer.start_link(__MODULE__, [], [name: @server])
  end

  # Callbacks

  def init(_args) do
    PubSub.subscribe_to(:text)
    persons = %{
      shadmi: %{
        regex: ~r/\b(שדמי|תום|נימר)\b/miu,
        responses:  ["אקסטרייייייייים", "תשמע הגזמנו אתמול", "וואה", "ווואייייי"]
      },
      nimrod: %{
        regex: ~r/\b(נימי|נמרוד|נימרוד|ניסים|נסים)\b/miu,
        responses: ["פרושיאנטה", "רדיוהד", "סורי נרדמתי"]
      },
      amit: %{
        regex: ~r/\b(עמיתו|עמית|גולדברג|בנתן)\b/miu,
        responses: ["¯\\_(ツ)_/¯", "רדיוהד מופעים פה מחר", "מפתיע", "יפתיע אותך?"]
      },
      yaron: %{
        regex: ~r/\b(ירון|חתול|חאתול)\b/miu,
        responses: ["טחח", "יא ז׳וז׳ו טחח", "פףף", "מה נז׳מע", "חתולה"]
      },
      yoav: %{
        regex: ~r/\b(יואב|יוחאפי|יוחאפ)\b/miu,
        responses: ["דן אריאלי", "הרוקו אחי", "נביא קצת טחינה עם כרובית?"]
      }
    }
    {:ok, persons}
  end

  def handle_info({:message, message}, state) do
    Enum.each(state, fn({person, person_settings}) -> GenServer.cast(@server, {person, person_settings, message}) end)
    {:noreply, state}
  end

  def handle_cast({_person, person_settings, message}, state) do
    %{regex: regex, responses: responses} = person_settings
    case Regex.match?(regex, message["text"]) do
      true ->
        response = Enum.random(responses)
        send_text(response, message)
      _ ->
        :ok
    end
    {:noreply, state}
  end

  defp send_text(text, message) do
    chat_id = message["chat"]["id"] # TODO
    BokerTovNissim.Messenger.send_text(chat_id, text, @response_probability)
  end
end
