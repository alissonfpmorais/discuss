defmodule Discuss.AuthController do
  use Discuss.Web, :controller
  plug Ueberauth
  alias Discuss.User

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, %{"code" => _code, "provider" => provider}) do
    response =
      %{name: auth.info.name, email: auth.info.email, token: auth.credentials.token, provider: provider}
      |> insert_or_update_user

    sign_in(conn, response)
  end

  defp insert_or_update_user(%{email: email} = user_params) do
    case Repo.get_by(User, email: email) do
      nil -> User.changeset(%User{}, user_params)
      user -> User.changeset(user, user_params)
    end
    |> Repo.insert_or_update
  end

  defp sign_in(conn, response) do
    case response do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Welcome back!")
        |> put_session(:user_id, user.id)
        |> redirect(to: topic_path(conn, :index))
      {:error, _reason} ->
        conn
        |> put_flash(:error, "Error signing in")
        |> redirect(to: topic_path(conn, :index))
    end
  end
end
