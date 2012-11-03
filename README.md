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

    20:27:19.039 [info] Launching: 2
    20:27:19.074 [info] 2: open: 15326 us
    20:27:19.075 [info] 1: open: 15923 us
    20:27:19.076 [info] 2: send: 1999 us
    20:27:19.077 [info] 1: send: 1478 us
    20:27:19.077 [info] 2: total: 19291 us
    20:27:19.077 [info] 2: recv: 200|323|785 us
    20:27:19.077 [info] 1: total: 19444 us
    20:27:19.077 [info] 2: Finished
    20:27:19.078 [info] 1: recv: 200|323|874 us
    20:27:19.078 [info] 1: Finished
    20:27:19.078 [info] Total: 33620 us

 * The operations are measured in microseconds.
 * The "open: xxx us" line indicates how much it took to establish the tcp connection.
 * The "recv: .." line indicates (separated by `|`):
  * HTTP status code.
  * Body length.
  * Time it took to receive the data.

## Defaults

 * GET method
 * HTTP 1.0

## Options

 * `--http11`
 * `--method get|post|put|delete|head|options|connect`
