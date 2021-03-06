# -------------------------------------------------------------------------------------------------
#  Copyright (C) 2015-2021 Nautech Systems Pty Ltd. All rights reserved.
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

from decimal import Decimal

from nautilus_trader.core.message cimport Event
from nautilus_trader.indicators.average.ema cimport ExponentialMovingAverage
from nautilus_trader.model.bar cimport Bar
from nautilus_trader.model.bar cimport BarSpecification
from nautilus_trader.model.bar cimport BarType
from nautilus_trader.model.c_enums.order_side cimport OrderSide
from nautilus_trader.model.identifiers cimport Symbol
from nautilus_trader.model.instrument cimport Instrument
from nautilus_trader.model.objects cimport Quantity
from nautilus_trader.model.order cimport MarketOrder
from nautilus_trader.model.tick cimport QuoteTick
from nautilus_trader.model.tick cimport TradeTick
from nautilus_trader.trading.strategy cimport TradingStrategy

# Notes for strategies written in Cython
# --------------------------------------
# except * in void methods allow C and Python exceptions to bubble up (otherwise they are ignored)

cdef class EMACross(TradingStrategy):
    """
    A simple moving average cross example strategy.

    When the fast EMA crosses the slow EMA then enter a position in that
    direction.
    """
    # Backing fields are necessary
    cdef Symbol symbol
    cdef BarType bar_type
    cdef object trade_size
    cdef ExponentialMovingAverage fast_ema
    cdef ExponentialMovingAverage slow_ema

    def __init__(
        self,
        Symbol symbol,
        BarSpecification bar_spec,
        trade_size: Decimal,
        int fast_ema=10,
        int slow_ema=20,
    ):
        """
        Initialize a new instance of the `EMACross` class.

        Parameters
        ----------
        symbol : Symbol
            The symbol for the strategy.
        bar_spec : BarSpecification
            The bar specification for the strategy.
        trade_size : Decimal
            The position size per trade.
        fast_ema : int
            The fast EMA period.
        slow_ema : int
            The slow EMA period.

        """
        # The order_id_tag should be unique at the 'trader level', here we are
        # just using the traded instruments symbol as the strategy order id tag.
        super().__init__(order_id_tag=symbol.code.replace('/', ''))

        # Custom strategy variables
        self.symbol = symbol
        self.bar_type = BarType(symbol, bar_spec)
        self.trade_size = trade_size

        # Create the indicators for the strategy
        self.fast_ema = ExponentialMovingAverage(fast_ema)
        self.slow_ema = ExponentialMovingAverage(slow_ema)

    cpdef void on_start(self) except *:
        """Actions to be performed on strategy start."""
        # Register the indicators for updating
        self.register_indicator_for_bars(self.bar_type, self.fast_ema)
        self.register_indicator_for_bars(self.bar_type, self.slow_ema)

        # Get historical data
        self.request_bars(self.bar_type)

        # Subscribe to live data
        self.subscribe_bars(self.bar_type)

    cpdef void on_instrument(self, Instrument instrument) except *:
        """
        Actions to be performed when the strategy is running and receives an
        instrument.

        Parameters
        ----------
        instrument : Instrument
            The instrument received.

        """
        pass

    cpdef void on_quote_tick(self, QuoteTick tick) except *:
        """
        Actions to be performed when the strategy is running and receives a quote tick.

        Parameters
        ----------
        tick : QuoteTick
            The tick received.

        """
        pass

    cpdef void on_trade_tick(self, TradeTick tick) except *:
        """
        Actions to be performed when the strategy is running and receives a trade tick.

        Parameters
        ----------
        tick : TradeTick
            The tick received.

        """
        # self.log.info(f"Received {tick}")  # For debugging (must add a subscription)
        pass

    cpdef void on_bar(self, BarType bar_type, Bar bar) except *:
        """
        Actions to be performed when the strategy is running and receives a bar.

        Parameters
        ----------
        bar_type : BarType
            The bar type received.
        bar : Bar
            The bar received.

        """
        self.log.info(f"Received {bar_type} Bar({bar})")

        # Check if indicators ready
        if not self.indicators_initialized():
            self.log.info(f"Waiting for indicators to warm up "
                          f"[{self.data.bar_count(self.bar_type)}]...")
            return  # Wait for indicators to warm up...

        # BUY LOGIC
        if self.fast_ema.value >= self.slow_ema.value:
            if self.portfolio.is_flat(self.symbol):
                self.buy()
            elif self.portfolio.is_net_short(self.symbol):
                self.flatten_all_positions(self.symbol)
                self.buy()

        # SELL LOGIC
        elif self.fast_ema.value < self.slow_ema.value:
            if self.portfolio.is_flat(self.symbol):
                self.sell()
            elif self.portfolio.is_net_long(self.symbol):
                self.flatten_all_positions(self.symbol)
                self.sell()

    cpdef void buy(self) except *:
        """
        Users simple buy method (example).
        """
        cdef MarketOrder order = self.order_factory.market(
            symbol=self.symbol,
            order_side=OrderSide.BUY,
            quantity=Quantity(self.trade_size),
        )

        self.submit_order(order)

    cpdef void sell(self) except *:
        """
        Users simple sell method (example).
        """
        cdef MarketOrder order = self.order_factory.market(
            symbol=self.symbol,
            order_side=OrderSide.SELL,
            quantity=Quantity(self.trade_size),
        )

        self.submit_order(order)

    cpdef void on_data(self, data) except *:
        """
        Actions to be performed when the strategy is running and receives a data object.

        Parameters
        ----------
        data : object
            The data object received.

        """
        pass

    cpdef void on_event(self, Event event) except *:
        """
        Actions to be performed when the strategy is running and receives an event.

        Parameters
        ----------
        event : Event
            The event received.

        """
        pass

    cpdef void on_stop(self) except *:
        """
        Actions to be performed when the strategy is stopped.

        """
        self.cancel_all_orders(self.symbol)
        self.flatten_all_positions(self.symbol)

    cpdef void on_reset(self) except *:
        """
        Actions to be performed when the strategy is reset.

        """
        pass

    cpdef dict on_save(self):
        """
        Actions to be performed when the strategy is saved.

        Create and return a state dictionary of values to be saved.

        Notes
        -----
        'OrderIdCount' is a reserved key for the returned state dictionary.

        """
        return {}

    cpdef void on_load(self, dict state) except *:
        """
        Actions to be performed when the strategy is loaded.

        Saved state values will be contained in the give state dictionary.

        Parameters
        ----------
        state : dict
            The strategy state dictionary.

        """
        pass

    cpdef void on_dispose(self) except *:
        """
        Actions to be performed when the strategy is disposed.

        Cleanup any resources used by the strategy here.

        """
        self.unsubscribe_bars(self.bar_type)
