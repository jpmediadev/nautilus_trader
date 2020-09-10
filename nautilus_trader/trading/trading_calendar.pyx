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

from cpython.datetime cimport datetime
from cpython.datetime cimport time
from cpython.datetime cimport tzinfo
from cpython.datetime cimport date

from nautilus_trader.trading.trading_session cimport TradingSession
from nautilus_trader.trading.trading_session cimport TradingSessionType


cdef class TradingCalendar:
    """
    Unimplemented TradingCalendar.
    """
    def __init__(self, tzinfo tz):
        self.tz = tz

    cdef TradingSession current_session(self, datetime utc_now):
        raise NotImplementedError("current_session")


cdef class NaiveTradingCalendar(TradingCalendar):
    cdef readonly time session_start
    cdef readonly time session_end

    """
    This is a "dumb" trading calendar that has no inkling of holidays
    and assumes trading hours are regular-only, M-F.
    This also has the limiting assumption that sessions do not span date boundaries.
    """
    def __init__(self, tzinfo tz, time session_start, time session_end):
        super().__init__(tz)
        self.session_start = session_start
        self.session_end = session_end

    @staticmethod
    cdef bint is_weekday(date d):
        """Skip if it is a weekend (Monday is day 0) """
        return d.weekday() in (0, 1, 2, 3, 4)

    cdef TradingSession current_session(self, datetime utc_now):
        # Convert UTC to local timestamp and day/time
        cdef datetime local_now = utc_now.astimezone(self.tz)
        cdef date local_day = local_now.date()

        if not NaiveTradingCalendar.is_weekday(local_day):
            return None

        cdef time local_time = local_now.time()

        # Check if current time is within session boundaries
        if self.session_start <= local_time < self.session_end:

            # Return a new regular TradingSession
            return TradingSession(
                session_start=local_day + self.session_start,
                session_end=local_day + self.session_end,
                session_type=TradingSessionType.REGULAR,
            )
        else:
            return None
