#include <faabric/util/bytes.h>
#include <faabric/util/http.h>
#include <faabric/util/logging.h>

#include <pistache/async.h>
#include <pistache/client.h>
#include <pistache/http.h>
#include <pistache/http_header.h>
#include <pistache/net.h>

#include <cstdlib>
#include <cstring>
#include <fstream>
#include <iostream>
#include <sstream>
#include <string>

using namespace Pistache;

namespace faabric::util {
std::vector<uint8_t> readFileFromUrl(const std::string& url)
{
    return readFileFromUrlWithHeader(url, nullptr);
}

std::vector<uint8_t> readFileFromUrlWithHeader(
  const std::string& url,
  const std::shared_ptr<Http::Header::Header>& header)
{
    Http::Client client;
    auto opts = Http::Client::options();
    client.init(opts);

    auto requestBuilder = client.get(url);

    if (header != nullptr) {
        requestBuilder.header(header);
    }

    // auto contentHeader =
    //   Http::Header::ContentType(MIME(Application, OctetStream));
    // auto acceptHeader = Http::Header::Accept();
    // acceptHeader.parseRaw("*/*", sizeof("*/*"));

    // requestBuilder.header<Http::Header::ContentType>(contentHeader);
    // requestBuilder.header<Http::Header::Accept>(acceptHeader);

    // Set up the request and callbacks
    auto resp =
      requestBuilder.timeout(std::chrono::milliseconds(HTTP_FILE_TIMEOUT))
        .send();

    std::stringstream out;
    Http::Code respCode;
    bool success = true;
    resp.then(
      [&](Http::Response response) {
          respCode = response.code();
          if (respCode == Http::Code::Ok) {
              auto body = response.body();
              out << body;
          } else {
              success = false;
          }
      },
      [&](std::exception_ptr exc) {
          PrintException excPrinter;
          excPrinter(exc);
          success = false;
      });

    // Make calls synchronous
    Async::Barrier<Http::Response> barrier(resp);
    std::chrono::milliseconds timeout(HTTP_FILE_TIMEOUT);
    barrier.wait_for(timeout);

    client.shutdown();

    // Check the response
    if (!success) {
        std::string msg =
          fmt::format("Error reading file from {} ({})", url, respCode);
        throw FaabricHttpException(msg);
    }

    return faabric::util::stringToBytes(out.str());
}
}
