defmodule SecureMessenger.MessageController do
  use SecureMessenger.Web, :controller
  alias SecureMessenger.Repo
  alias SecureMessenger.Message
  import Logger

  def create(conn, %{"message" => message_params}) do
    user = Guardian.Plug.current_resource(conn)
    if message_params["incognito"] == "true" do
      temp_id = :rand.uniform(9999)
        conn
        |> json %{
          message: Phoenix.View.render_to_string(SecureMessenger.MessageView, "secure_message.html", conn: conn, temp_id: temp_id, user: user, message: message_params["body"]),
          temp_id: temp_id,
          room_id: message_params["room_id"]
        }
    else
      changeset = Message.changeset(%Message{user_id: user.id}, message_params)
      case Repo.insert(changeset) do
        {:ok, message} ->
          conn
          |> json %{
            message: Phoenix.View.render_to_string(SecureMessenger.MessageView, "message.html", conn: conn, message: message |> Repo.preload([:user])),
            room_id: message_params["room_id"],
            temp_id: nil
         }
        {:error, changeset} ->
          conn
      end
    end

    # changeset = Room.changeset(%Room{owner_id: current_user(conn).id}, room_params)
    #
    # case Repo.insert(changeset) do
    #   {:ok, _room} ->
    #     conn
    #     |> put_flash(:info, "Room created successfully.")
    #     |> redirect(to: room_path(conn, :index))
    #   {:error, changeset} ->
    #     conn
    #     |> put_flash(:error, "Problem creating a new room.")
    #     |> redirect(to: room_path(conn, :new), changeset: changeset)

  #   case MyApp.Session.login(user_params, MyApp.Repo) do
    #  conn
    #  |> json %{ message: Phoenix.View.render_to_string(SecureMessenger.MessageView, "message.html", conn: conn) }

   end

end
