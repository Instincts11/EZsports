from __future__ import annotations

import base64
import json
from urllib.error import HTTPError, URLError
from urllib.parse import urlencode
from urllib.request import Request, urlopen

from fastapi import status

from app.core.config import settings
from app.core.exceptions import AppError


def _e164(mobile: str) -> str:
    digits = "".join(ch for ch in mobile if ch.isdigit())
    if digits.startswith(settings.sms_country_code) and len(digits) > 10:
        return f"+{digits}"
    return f"+{settings.sms_country_code}{digits[-10:]}"


def send_otp_sms(mobile: str, otp: str) -> None:
    provider = settings.sms_provider.strip().lower()
    if provider != "twilio":
        raise AppError(
            status.HTTP_503_SERVICE_UNAVAILABLE,
            "SMS is not configured, so the code cannot be sent to the mobile.",
        )

    account_sid = settings.twilio_account_sid.strip()
    auth_token = settings.twilio_auth_token.strip()
    from_number = settings.twilio_from_number.strip()
    if not account_sid or not auth_token or not from_number:
        raise AppError(
            status.HTTP_503_SERVICE_UNAVAILABLE,
            "SMS is not configured, so the code cannot be sent to the mobile.",
        )

    body = urlencode(
        {
            "To": _e164(mobile),
            "From": from_number,
            "Body": f"ID Sports code: {otp}. Enter this code from your mobile. It expires in 10 minutes.",
        }
    ).encode()
    token = base64.b64encode(f"{account_sid}:{auth_token}".encode()).decode()
    request = Request(
        f"https://api.twilio.com/2010-04-01/Accounts/{account_sid}/Messages.json",
        data=body,
        headers={"Authorization": f"Basic {token}"},
        method="POST",
    )
    try:
        with urlopen(request, timeout=20) as response:
            if response.status >= 300:
                raise AppError(status.HTTP_502_BAD_GATEWAY, "The code could not be sent to the mobile.")
    except HTTPError as error:
        detail = "The code could not be sent to the mobile."
        try:
            payload = json.loads(error.read().decode())
            message = payload.get("message")
            if isinstance(message, str) and message.strip():
                detail = message.strip()
        except (OSError, ValueError, json.JSONDecodeError):
            pass
        raise AppError(status.HTTP_502_BAD_GATEWAY, detail) from error
    except URLError as error:
        raise AppError(status.HTTP_502_BAD_GATEWAY, "The code could not be sent to the mobile.") from error
