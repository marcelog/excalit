# Excalit

## License

This software is under the Apache2 License. See the [LICENSE](https://github.com/marcelog/excalit/blob/master/LICENSE) file.

## About

Stress testing tool for web servers, written in [elixir](http://elixir-lang.org/).

Will launch *N* concurrent connections, make a request, and measure how much time took to:

 * Open the connection
 * Receive the response

## Sample run

    $ mix excalit --url http://localhost:8080/ --concurrent 2

    12:19:27.696 [info] Launching: 2
    12:19:27.732 [info] 2: open: 15680 us
    12:19:27.732 [info] 1: open: 15796 us
    12:19:27.734 [info] 2: send: 2079 us
    12:19:27.734 [info] 1: send: 2043 us
    12:19:27.734 [info] 2: total: 19402 us
    12:19:27.734 [info] 2: recv: 200|323|420 us
    12:19:27.734 [info] 2: Finished
    12:19:27.735 [info] 1: total: 20227 us
    12:19:27.735 [info] 1: recv: 200|323|1172 us
    12:19:27.735 [info] 1: Finished
    12:19:27.735 [info] TCP connect time best: 2: 15680 us
    12:19:27.736 [info] TCP connect time worst: 1: 15796 us
    12:19:27.736 [info] TCP connect time 50% took: 15680 us
    12:19:27.736 [info] TCP connect time 100% took: 15796 us
    12:19:27.736 [info] Recv data best: 2: 420 us
    12:19:27.736 [info] Recv data worst: 1: 1172 us
    12:19:27.736 [info] Recv data 50% took: 420 us
    12:19:27.737 [info] Recv data 100% took: 1172 us
    12:19:27.737 [info] Total: 34847 us

 * The operations are measured in microseconds.
 * The "open: xxx us" line indicates how much it took to establish the tcp connection.
 * The "recv: .." line indicates (separated by `|`):
  * HTTP status code.
  * Body length.
  * Time it took to receive the data.

## Defaults

 * GET method
 * HTTP 1.0
 * 1 connection

## Options

 * `--http11`
 * `--method get|post|put|delete|head|options|connect`
 * `--concurrent n`
