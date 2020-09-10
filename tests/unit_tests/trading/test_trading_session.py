# -------------------------------------------------------------------------------------------------
#  Licensed under the GNU Lesser General Public License Version 3.0 (the "License");
#  You may not use this file except in compliance with the License.
#  You may obtain a copy of the License at https://www.gnu.org/licenses/lgpl-3.0.en.html
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
# -------------------------------------------------------------------------------------------------

from datetime import datetime
from datetime import timedelta
from datetime import tzinfo
import unittest

import pytz

from nautilus_trader.model.enums import TradingSessionType
from nautilus_trader.trading.trading_session import TradingSession


class TradingSessionTests(unittest.TestCase):
    def test_is_in_utc_session(self):
        """If the local time is UTC, ensure session-checking works."""
        utc_tz: tzinfo = pytz.utc
        session: TradingSession = TradingSession(
            session_start=datetime(2020, 1, 1, 9, 30, 0, tzinfo=utc_tz),
            session_end=datetime(2020, 1, 1, 16, 0, 0, tzinfo=utc_tz),
            session_type=TradingSessionType.REGULAR,
        )

        # Within time bounds, but on the previous day
        self.assertFalse(session.is_in_session(
            datetime(2019, 1, 1, 10, 0, 0, tzinfo=utc_tz)
        ))
        # Before time bounds, on the same day
        self.assertFalse(session.is_in_session(
            datetime(2020, 1, 1, 9, 0, 0, tzinfo=utc_tz)
        ))

        # At the starting bound, on the same day
        self.assertTrue(session.is_in_session(
            datetime(2020, 1, 1, 9, 30, 0, tzinfo=utc_tz)
        ))
        # Between time bounds, on the same day
        self.assertTrue(session.is_in_session(
            datetime(2020, 1, 1, 9, 31, 0, tzinfo=utc_tz)
        ))

        # At the end bound, on the same day
        self.assertFalse(session.is_in_session(
            datetime(2020, 1, 1, 16, 0, 0, tzinfo=utc_tz)
        ))
        # After the end bound, on the same day
        self.assertFalse(session.is_in_session(
            datetime(2020, 1, 1, 16, 1, 0, tzinfo=utc_tz)
        ))

    def test_is_in_non_utc_session(self):
        """If the local time is non-UTC, ensure session-checking works."""
        utc_tz: tzinfo = pytz.utc
        local_tz: tzinfo = pytz.timezone("America/New_York")
        session: TradingSession = TradingSession(
            session_start=datetime(2020, 1, 1, 9, 30, 0, tzinfo=local_tz),
            session_end=datetime(2020, 1, 1, 16, 0, 0, tzinfo=local_tz),
            session_type=TradingSessionType.REGULAR,
        )
        # For ease of test maintenance, offset the input UTC times by the offset
        # between the local and UTC timezones.
        offset: timedelta = local_tz.utcoffset(session.session_start)

        # Within time bounds, but on the previous day
        self.assertFalse(session.is_in_session(
            datetime(2019, 1, 1, 10, 0, 0, tzinfo=utc_tz) - offset
        ))
        # Before time bounds, on the same day
        self.assertFalse(session.is_in_session(
            datetime(2020, 1, 1, 9, 0, 0, tzinfo=utc_tz) - offset
        ))

        # At the starting bound, on the same day
        self.assertTrue(session.is_in_session(
            datetime(2020, 1, 1, 9, 30, 0, tzinfo=utc_tz) - offset
        ))
        # Between time bounds, on the same day
        self.assertTrue(session.is_in_session(
            datetime(2020, 1, 1, 9, 31, 0, tzinfo=utc_tz) - offset
        ))

        # At the end bound, on the same day
        self.assertFalse(session.is_in_session(
            datetime(2020, 1, 1, 16, 0, 0, tzinfo=utc_tz) - offset
        ))
        # After the end bound, on the same day
        self.assertFalse(session.is_in_session(
            datetime(2020, 1, 1, 16, 1, 0, tzinfo=utc_tz) - offset
        ))

    def test_is_in_session_requires_utc_input(self):
        """Ensure that `is_in_session` requires a UTC input."""
        session: TradingSession = TradingSession(
            session_start=datetime(2020, 1, 1, 9, 30, 0, tzinfo=pytz.utc),
            session_end=datetime(2020, 1, 1, 16, 0, 0, tzinfo=pytz.utc),
            session_type=TradingSessionType.REGULAR,
        )

        # Throw error for non-UTC
        with self.assertRaises(ValueError):
            session.is_in_session(
                datetime(2019, 1, 1, 10, 0, 0, tzinfo=pytz.timezone("America/New_York"))
            )

        # Do not throw error for UTC input
        session.is_in_session(
            datetime(2019, 1, 1, 10, 0, 0, tzinfo=pytz.utc)
        )
