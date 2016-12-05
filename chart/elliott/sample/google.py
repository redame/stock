#!/bin/env python
#
import pandas as pd
import pandas.io.data as web
from qrzigzag import peak_valley_pivots, max_drawdown, compute_segment_returns, pivots_to_modes

X = web.get_data_yahoo('GOOG')['Adj Close']
pivots = peak_valley_pivots(X, 0.2, -0.2)
ts_pivots = pd.Series(X, index=X.index)
ts_pivots = ts_pivots[pivots != 0]
X.plot()
ts_pivots.plot(style='g-o')