# Business Problem and KPIs

## Scenario

Maven Fuzzy Factory is an online stuffed-animal retailer. Between March 2012 and March 2015 it grew to 32,313 orders and $1.94M in revenue. Imagine the CEO asks before a board meeting:

> *"Revenue is growing, but are we growing in a healthy way? Which traffic channels and products actually earn their keep, and where are we exposed?"*

Two risks were visible in the data before any analysis:

- **Channel dependence:** one paid channel, Google non-brand search, brings 282,706 of 472,871 sessions (about 60%).
- **Product dependence:** one product, The Original Mr. Fuzzy, is about 60% of items sold and 62.5% of revenue.

## The 5 KPIs

| # | KPI | Definition | Tables |
|---|---|---|---|
| 1 | Conversion rate | orders ÷ sessions | orders, website_sessions |
| 2 | Revenue per session | revenue ÷ sessions | orders, website_sessions |
| 3 | Average order value (AOV) | revenue ÷ orders | orders |
| 4 | Gross margin % | (revenue − COGS) ÷ revenue | order_items |
| 5 | Refund rate | refunded items ÷ items sold, by product | order_items, order_item_refunds |

KPIs 1 and 2 are cut by traffic channel, KPIs 4 and 5 by product, and all of them over time.

## Caveats

- The first and last months are partial: the data runs from 2012-03-19 to 2015-03-19, and 2015 is a partial year.
- Refunds continue to 2015-04-01 while orders stop on 2015-03-19, so the most recent orders may not yet show their refunds. Recent refund rates may be understated.
- Conversion rate treats every session as eligible to buy.
- There is no marketing spend data, so channel return on investment cannot be calculated.
- Monthly queries differ in how they attribute orders: the conversion trend uses the session month, and the revenue trend uses the order month.
