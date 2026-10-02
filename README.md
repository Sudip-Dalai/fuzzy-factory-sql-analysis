# Maven Fuzzy Factory: SQL Analysis of E-Commerce Growth

An end-to-end MySQL project on a practice dataset from a fictional online toy retailer (about 473k website sessions, 32k orders, March 2012 to March 2015). It covers building a typed relational schema, cleaning on load, validating the data, and answering a business question with SQL.

## The business question

> Revenue is growing, but is it growing in a healthy way? Which traffic channels and products earn their keep, and where is the company exposed?

## Key findings

| Area | Finding |
|---|---|
| Growth | $1.94M revenue across 32,313 orders. Conversion rose from about 3% (2012) to about 8% (early 2015); revenue per session rose from $1.60 to about $5.20. The data does not show why. |
| Channel dependence | Google non-brand search is 282,706 of 472,871 sessions (about 60%). Its share of revenue fell from 67.5% (2012) to 55.9% (2014) but is still over half. |
| Weak channel | The Socialbook pilot converted 1.08% of 5,095 sessions and earned $0.73 per session, versus 6.7% to 8.9% for the search channels. No spend data was available, so ROI was not calculated. |
| Product dependence | The Original Mr. Fuzzy is 62.5% of revenue. |
| Refunds | The Birthday Sugar Panda has the best margin (68.5%) but the highest refund rate (6.04%). The Hudson River Mini bear sells mostly as an add-on (88% of its sales). |
| Repeat business | The 90-day repeat rate rose from about 0.6% to 0.9% (2012 cohorts) to about 1.9% to 2.2% (2014 cohorts), but stays low. Of 591 customers who reordered, 97.8% did so within 90 days (average 35.2 days). |

## Data and schema

Five tables from the Maven Analytics Toy Store E-Commerce Database, linked by foreign keys: `products`, `website_sessions`, `orders`, `order_items`, `order_item_refunds`. See [`data/README.md`](data/README.md) for the download link. The CSV files are not stored in this repo. `website_pageviews` (about 1.2M rows) was not used.

## Data quality work

- **Missing values stored as the text "NULL".** The sessions file wrote missing values as the word `NULL`. Loaded as-is, `IS NULL` filters and `COUNT()` would be wrong. I converted 289,901 text values (83,328 each in three UTM columns, plus 39,917 in the referrer column) to true NULLs at load time using `NULLIF`, and verified none remained.
- **Windows line endings** (`\r\n`) handled in the load statements.
- **Reconciliation checks** ([`03_validation_checks.sql`](sql/03_validation_checks.sql)): row counts match the source files; order revenue equals item revenue ($1,938,509.75); refund total matches the source ($85,338.69).
- **Profiling before loading:** no duplicate IDs, no orphan keys, consistent timestamp formats. The data was otherwise clean, so cleaning effort went into the NULL fix and validation.

## SQL techniques

| Tier | File | Techniques |
|---|---|---|
| Foundational | [`04_foundational_queries.sql`](sql/04_foundational_queries.sql) | Multi-table `JOIN`, `LEFT JOIN`, `GROUP BY`, `CASE WHEN` |
| Intermediate | [`05_intermediate_queries.sql`](sql/05_intermediate_queries.sql) | CTEs, subquery, date-based cohort analysis |
| Advanced | [`06_advanced_queries.sql`](sql/06_advanced_queries.sql) | `LAG`, running total, moving average, `DENSE_RANK`, `ROW_NUMBER`, self-join |
| Performance | [`07_indexes_explain.sql`](sql/07_indexes_explain.sql) | Indexes with `EXPLAIN` before and after |

**Performance note:** an index on `website_sessions(created_at)` changed the plan from a full table scan (about 468,531 rows examined) to an index range scan (about 29,086 estimated rows). An index on `orders(user_id, created_at)` took a customer lookup from about 32,448 rows to 3. The tables are small, so wall-clock time was already low and I did not measure a speedup.

## How to reproduce

1. Download the CSVs (see `data/README.md`).
2. Run `sql/01_schema_ddl.sql`.
3. Edit the file paths in `sql/02_load_data.sql` and run it. This needs `local_infile` enabled on the server and `OPT_LOCAL_INFILE=1` in the client connection.
4. Run `sql/03_validation_checks.sql` and compare with the expected results in its comments.
5. Run the query files `04` to `07`.

Built with MySQL 8.0.

## Limitations

- The first and last months are partial (data runs from 2012-03-19 to 2015-03-19), and 2015 is a partial year.
- Conversion improved, but this analysis does not identify why. Product launches, channel mix and site changes could each contribute.
- No marketing spend data, so channel profitability and ROI were not calculated.
- Recent orders may have incomplete refund data, so recent refund rates may be understated.
- Every repeat order falls within 107 days of the first. That looks short for a three-year window, and I did not investigate why.
- Monthly queries differ in how they attribute orders: the conversion trend uses the session month, and the revenue trend uses the order month.
