# -------------------------------------------------------------------------------------------------
#  Copyright (C) 2015-2020 Nautech Systems Pty Ltd. All rights reserved.
#  https://nautechsystems.io
#
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

from nautilus_trader.model.bar cimport Bar
from nautilus_trader.model.bar cimport BarType


cdef class BarData:
    cdef BarType _bar_type
    cdef Bar _bar


cdef class BarDataBlock:
    cdef BarType _bar_type
    cdef list _bars


cdef class QuoteTickDataBlock:
    cdef list _ticks


cdef class TradeTickDataBlock:
    cdef list _ticks


cdef class InstrumentDataBlock:
    cdef list _instruments