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

from cpython.datetime cimport datetime, tzinfo
from nautilus_trader.core.correctness cimport Condition
from nautilus_trader.core.datetime cimport is_datetime_utc

from nautilus_trader.core.datetime cimport utc_as_local_datetime


cdef class TradingSession:
    def __init__(
        self,
        datetime session_start,
        datetime session_end,
        TradingSessionType session_type
    ):
        # Timezones must match
        assert session_start.tzinfo == session_end.tzinfo

        self.session_start = session_start
        self.session_end = session_end

        self.session_type = session_type

    cpdef tzinfo tz(self):
        """
        Return the timezone in use by this TradingSession.
        We know that the timezone on `session_start` and `session_end`
        are the same.
        """
        return self.session_start.tzinfo

    cpdef bint is_in_session(self, datetime utc_now) except *:
        """
        Return true if this session is open as of the UTC time argument.

        Parameters
        ----------
        utc_now : datetime
            The UTC time to test for the session's "open-ness".

        Returns
        -------
        bool
            True if in this session, else False.

        Raises
        ------
        ValueError
            If time_now is not tz aware UTC.
        """
        Condition.true(is_datetime_utc(utc_now), "utc_now is tz aware UTC")

        cdef datetime local_now = utc_as_local_datetime(utc_now, self.tz())
        return self.session_start <= local_now < self.session_end
