import io
import json
import urllib.error
from unittest.mock import patch

from tooling.exchange import request_json


class FakeResponse:
    def __init__(self, status: int, payload: dict):
        self.status = status
        self._body = json.dumps(payload).encode()

    def __enter__(self):
        return self

    def __exit__(self, *_args):
        return None

    def read(self) -> bytes:
        return self._body


def test_request_json_serializes_payload() -> None:
    with patch(
        "urllib.request.urlopen",
        return_value=FakeResponse(201, {"ok": True}),
    ) as urlopen:
        status, body = request_json(
            "POST",
            "http://example.invalid/shells",
            {"id": "shell"},
        )

    assert status == 201
    assert body == {"ok": True}
    request = urlopen.call_args.args[0]
    assert request.method == "POST"
    assert json.loads(request.data) == {"id": "shell"}


def test_request_json_returns_http_error_body() -> None:
    error = urllib.error.HTTPError(
        "http://example.invalid/shells",
        409,
        "Conflict",
        {},
        io.BytesIO(b'{"message":"exists"}'),
    )
    with patch("urllib.request.urlopen", side_effect=error):
        status, body = request_json(
            "POST",
            "http://example.invalid/shells",
            {"id": "shell"},
        )

    assert status == 409
    assert body == {"message": "exists"}

