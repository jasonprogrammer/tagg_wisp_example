import app/router
import app/web
import filepath
import gleam/dict
import gleam/erlang/process
import gleam/io
import tagg_config
import mist
import simplifile
import wisp
import wisp/wisp_mist

fn start_server(current_dir_path: String) {
  io.println("Starting server...")

  let tag_config = dict.from_list([])

  let web_context =
    web.Context(tagg_config.Tagg(filepath.join(current_dir_path, "web"), tag_config))

  // This sets the logger to print INFO level logs, and other sensible defaults
  // for a web application.
  wisp.configure_logger()

  // Here we generate a secret key, but in a real application you would want to
  // load this from somewhere so that it is not regenerated on every restart.
  let secret_key_base = wisp.random_string(64)

  let handler = router.handle_request(_, web_context)

  // Start the Mist web server.
  let assert Ok(_) =
    wisp_mist.handler(handler, secret_key_base)
    |> mist.new
    |> mist.port(8000)
    |> mist.start_http

  // The web server runs in new Erlang process, so put this one to sleep while
  // it works concurrently.
  process.sleep_forever()
}

pub fn main() {
  case simplifile.current_directory() {
    Ok(current_dir_path) -> {
      start_server(current_dir_path)
    }
    Error(_) -> {
      io.println("Failed to get current directory")
    }
  }
}
