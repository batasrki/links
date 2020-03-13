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

  get "/test/howto1.html" do
    body = """
    <html>
      <head>
        <title data-rh="true">\n    \n    How To Mock a Server Response\n    \n  </title>
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

  get "/test/429.html" do
    Plug.Conn.send_resp(conn, 429, "Too many requests")
  end

  get "/test/301.html" do
    conn
    |> Plug.Conn.put_resp_header("location", "http://localhost:8081/test/howto.html")
    |> Plug.Conn.send_resp(301, "Moved")
  end

  get "/test/302.html" do
    conn
    |> Plug.Conn.put_resp_header("location", "http://localhost:8081/test/howto.html")
    |> Plug.Conn.send_resp(302, "Moved again")
  end

  get "/test/500.html" do
    Process.sleep(:infinity)
    Plug.Conn.send_resp(conn, 500, "Server error")
  end

  get "/test/gzipped.html" do
    body = """
    <html>
      <head>
        <title data-rh="true">\n    \n    How To Mock a Server Response\n    \n  </title>
      </head>
      <body>
        <p>Does this work?</p>
      </body>
    </html>
    """

    conn
    |> Plug.Conn.put_resp_header("content-encoding", "gzip")
    |> Plug.Conn.send_resp(200, :zlib.gzip(body))
  end
end
