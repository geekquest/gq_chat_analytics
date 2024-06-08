from dataclasses import dataclass
from typing import Iterable, TextIO

import csv
import datetime
import io
import os
import re
import sys

import holidays


@dataclass
class Chat:
    timestamp: datetime.datetime
    sender: str | None
    message: str


@dataclass
class Date:
    date: datetime.date
    day: int
    week_day: int
    day_name: str
    month: int
    month_name: str
    year: int
    holiday: str | None


CHAT_HEADER_REGEX = re.compile(
    r"^(?P<date>\d{1,2}/\d{1,2}/\d{2}, \d{1,2}:\d{2}\u202f[AP]M) - (?P<sender>[^:]+:)?\s*(?P<message>.*)$"
)
CHAT_TIMESTAMP_FORMAT = "%m/%d/%y, %I:%M\u202f%p"


def main() -> None:
    seeds_dir = os.path.join(
        os.path.dirname(os.path.abspath(__file__)),
        "gq_transformations",
        "seeds",
    )

    # NOTE: Loading sensitive data as seeds is unwise...
    chats_csv = os.path.join(seeds_dir, "whatsapp-chats.csv")
    with open(chats_csv, "w", encoding="utf-8") as file:
        write_chats_to_file(parse_whatsapp_chats(sys.stdin.readlines()), file)

    calendar_csv = os.path.join(seeds_dir, "calendar.csv")
    with open(calendar_csv, "w", encoding="utf-8") as file:
        write_calendar_to_file(get_calendar(), file)

    print(f"Generated DBT seeds in {seeds_dir}")


def parse_whatsapp_chats(lines: Iterable[str]) -> Iterable[Chat]:
    chats: list[Chat] = []

    date: str | None = None
    sender: str | None = None
    message = io.StringIO()

    for line in lines:
        match = CHAT_HEADER_REGEX.match(line)

        if not match:
            message.write(" ")
            message.write(line.strip())
            continue

        if date:
            chat = Chat(
                timestamp=datetime.datetime.strptime(date, CHAT_TIMESTAMP_FORMAT),
                sender=sender,
                message=message.getvalue(),
            )
            chats.append(chat)

        date = match["date"]
        sender = match["sender"] and match["sender"].rstrip(":")
        message = io.StringIO(initial_value=match["message"])

    if date is not None:
        chat = Chat(
            timestamp=datetime.datetime.strptime(date, CHAT_TIMESTAMP_FORMAT),
            sender=sender,
            message=message.getvalue(),
        )
        chats.append(chat)

    return chats


def get_calendar(
    start_from=datetime.date.fromisoformat("2020-01-01"),
    to: datetime.date | None = None,
) -> Iterable[Date]:
    to = to or datetime.date.today()
    assert start_from <= to

    malawi_holidays = holidays.country_holidays("MWI")
    calendar: list[Date] = []

    while start_from <= to:
        date = Date(
            date=start_from,
            day=start_from.day,
            week_day=start_from.weekday(),
            day_name=start_from.strftime("%A"),
            month=start_from.month,
            month_name=start_from.strftime("%B"),
            year=start_from.year,
            holiday=malawi_holidays.get(start_from),
        )
        calendar.append(date)
        start_from += datetime.timedelta(days=1)

    return calendar


def write_chats_to_file(chats: Iterable[Chat], csv_file: TextIO) -> None:
    writer = csv.writer(csv_file)
    writer.writerow(("timestamp", "sender", "message"))

    for chat in chats:
        writer.writerow((chat.timestamp.isoformat(), chat.sender, chat.message))


def write_calendar_to_file(calendar: Iterable[Date], csv_file: TextIO) -> None:
    writer = csv.writer(csv_file)
    writer.writerow(
        (
            "date",
            "week_day",
            "day_name",
            "month",
            "month_name",
            "year",
            "holiday",
        )
    )

    for date in calendar:
        writer.writerow(
            (
                date.date,
                date.week_day,
                date.day_name,
                date.month,
                date.month_name,
                date.year,
                date.holiday,
            )
        )


if __name__ == "__main__":
    main()
