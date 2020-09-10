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

cpdef enum TradingSessionType:
    UNDEFINED = 0
    REGULAR = 1
    PRE_MARKET = 2
    AFTER_HOURS = 3
    ALL_HOURS = 4  # 24-hour session


cdef inline str trading_session_type_to_string(int value):
    if value == 1:
        return 'REGULAR'
    elif value == 2:
        return 'PRE_MARKET'
    elif value == 3:
        return 'AFTER_HOURS'
    elif value == 4:
        return 'ALL_HOURS'
    else:
        return 'UNDEFINED'


cdef inline TradingSessionType trading_session_type_from_string(str value):
    if value == 'REGULAR':
        return TradingSessionType.REGULAR
    elif value == 'PRE_MARKET':
        return TradingSessionType.PRE_MARKET
    elif value == 'AFTER_HOURS':
        return TradingSessionType.AFTER_HOURS
    elif value == 'ALL_HOURS':
        return TradingSessionType.ALL_HOURS
    else:
        return TradingSessionType.UNDEFINED
