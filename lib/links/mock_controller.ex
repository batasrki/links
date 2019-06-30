defmodule Links.MockController do
  use Plug.Router
  plug(:match)
  plug(:dispatch)

  get "/test/howto.html" do
    body = """
    <html>
      <head>
        <title data-rh="true">How To Mock a Server Response</title>
      </head>
      <body>
        <p>Does this work?</p>
      </body>
    </html>
    """

    Plug.Conn.send_resp(conn, 200, body)
  end

  get "/test/404.html" do
    Plug.Conn.send_resp(conn, 404, "Not Found")
  end
end
