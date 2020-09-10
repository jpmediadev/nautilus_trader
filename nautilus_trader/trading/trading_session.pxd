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

"""
A TradingSession describes a single "session" of trading. This includes a locale
(ie, a timezone) embedded into the start and end timestamps.
An asset may have zero to many trading sessions in a given day,
including regular and extended hours.
"""

from cpython.datetime cimport datetime
from cpython.datetime cimport tzinfo

from nautilus_trader.model.c_enums.trading_session_type cimport TradingSessionType


cdef class TradingSession:
    cdef readonly datetime session_start  # inclusive
    cdef readonly datetime session_end  # exclusive

    cdef readonly TradingSessionType session_type

    cpdef tzinfo tz(self)
    cpdef bint is_in_session(self, datetime utc_now) except *
