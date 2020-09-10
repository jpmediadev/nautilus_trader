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

from cpython.datetime cimport tzinfo

from nautilus_trader.model.identifiers cimport ExchangeId
from nautilus_trader.trading.trading_calendar cimport TradingCalendar


cdef class Exchange:
    cdef readonly ExchangeId id

    cdef readonly tzinfo tz
    cdef readonly TradingCalendar calendar
