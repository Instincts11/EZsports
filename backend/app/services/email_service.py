from __future__ import annotations

import smtplib
from email.message import EmailMessage

from fastapi import status

from app.core.config import settings
from app.core.exceptions import AppError


def send_password_email(to_email: str, password: str) -> None:
    host = settings.smtp_host.strip()
    sender = settings.smtp_from.strip() or settings.smtp_username.strip()
    if not host or not sender:
        raise AppError(
            status.HTTP_503_SERVICE_UNAVAILABLE,
            "Email is not configured, so the password cannot be sent.",
        )

    message = EmailMessage()
    message["Subject"] = "Your ID Sports password"
    message["From"] = sender
    message["To"] = to_email
    message.set_content(
        "Your ID Sports password is "
        f"{password}.\n\nEnter this password from your email to sign in. "
        "It expires in 10 minutes."
    )

    try:
        with smtplib.SMTP(host, settings.smtp_port, timeout=20) as smtp:
            if settings.smtp_use_tls:
                smtp.starttls()
            username = settings.smtp_username.strip()
            if username:
                smtp.login(username, settings.smtp_password)
            smtp.send_message(message)
    except (OSError, smtplib.SMTPException) as error:
        raise AppError(
            status.HTTP_502_BAD_GATEWAY,
            "The password could not be sent to the email.",
        ) from error
