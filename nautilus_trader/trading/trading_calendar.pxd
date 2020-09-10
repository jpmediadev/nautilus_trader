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
from cpython.datetime cimport tzinfo

from nautilus_trader.trading.trading_session cimport TradingSession


cdef class TradingCalendar:
    cdef readonly tzinfo tz

    # cdef TradingSession prev_session(self, datetime utc_now)  # Return None if not found
    cdef TradingSession current_session(self, datetime utc_now)  # Return None if not in a session
    # cdef TradingSession next_session(self, datetime utc_now)  # Return None if not found
    # cdef list next_sessions(self, next_n)
