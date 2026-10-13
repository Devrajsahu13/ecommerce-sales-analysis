# E-Commerce Sales & Delivery Analysis

Analysis of about 96,000 delivered orders from Olist, a Brazilian online marketplace (Jan 2017 – Aug 2018). I loaded the raw data into MySQL with Python, answered six business questions in SQL, and built a 3-page Power BI dashboard.

**Short version:** growth stalled in 2018, late deliveries are one of the biggest reasons for bad reviews, and almost no customers come back for a second order.

## Dashboard

   ![Sales Overview](dashboard/page1_sales.png)

   ![Delivery & Satisfaction](dashboard/page2_delivery.png)

   ![Customers & Sellers](dashboard/page3_customers.png)

## Questions and findings

### Q1. Is the business still growing?

Orders went up fast through 2017, from 750 in January to 7,289 in November. November was the biggest jump of the year (+52%), which lines up with Black Friday. After that it flattens out. All of 2018 sits around 6,000 to 7,000 orders a month, with revenue between roughly 830K and 980K. So growth basically stopped in 2018, and that's what I wanted to dig into with the rest of the questions.

I dropped 2016 and everything after Aug 2018 because those months only had a few orders, and the growth % came out ridiculous (one month showed over 29,000%).

### Q2. Which categories bring in the most money?

Health & beauty brings in the most, around 1.26M. Watches & gifts is close behind at 1.21M, even though it had about 3,000 fewer orders. Its items just cost more (around 201 on average, the highest in the top 10). Bed, bath & table actually had the most orders of any category (9,417), but it only comes 3rd in revenue because the items are cheap, around 93 each.

So the most popular category isn't the one making the most money. If I were the business, I'd look at pushing watches & gifts harder, since each sale is worth more than twice a bed & bath sale.

*(These numbers come from SQL, which counts all orders. The dashboard only counts delivered orders, so it shows slightly lower values, e.g. 1.23M for health & beauty.)*

### Q3. Do late deliveries hurt reviews?

Yes, by a lot. About 8% of orders arrived after the date the customer was promised (7,700 out of roughly 96,000). On-time orders average 4.29 stars, but late ones drop to 2.57. The bigger number for me is bad reviews: 54% of late orders got 1 or 2 stars, compared to 9.2% for on-time orders. That's about 6 times more.

This was the clearest result in the whole analysis. Late delivery isn't a small annoyance, it basically turns a happy customer into an unhappy one. And unhappy customers don't come back, which could be part of why growth stalled in 2018.

### Q4. Which states get the worst delivery?

The worst delivery is in the north and northeast. Maranhão (MA) had almost 20% of orders arrive late, and customers in states like MA, CE and PA waited 20 to 24 days on average. São Paulo is the opposite: it's by far the biggest market (40K+ orders) but only 5.9% late, and deliveries take under 9 days.

The one I'd actually flag first is Rio de Janeiro. MA has the worst rate, but only around 700 orders. RJ is the second biggest market, it's close to São Paulo, and it still has 13.5% late, more than double SP. That's around 1,670 late orders, so fixing delivery in RJ would probably help the most customers.

### Q5. Do customers come back?

Almost never. Out of about 93,000 customers, only 3% ever placed a second order, so 97% bought once and that was it.

One thing I had to fix here: at first I thought customer_id was the customer, but it's actually different on every order. Using it, nobody would ever look like a repeat buyer. I switched to customer_unique_id, which stays the same for a person.

Putting this together with Q1 and Q3: the business basically has to find a whole new set of customers every month just to stay flat. That fits with growth stalling in 2018. Getting even a small share of people to come back, through better delivery or a simple "buy again" offer, would probably do more than spending on new customers.

### Q6. How much do the top sellers matter?

No single seller is a big risk. The biggest one only brings in about 1.7% of total revenue. But when I added up the top 20, they make about 21% of all revenue together, and that's out of about 3,000 sellers. So less than 1% of sellers bring in a fifth of the money.

I'd say the business is safe from losing any one seller, but this small group is worth looking after. Things like giving them priority support or faster payouts would make sense, because losing several of them at once would hurt.

## Recommendations

1. Fix delivery in Rio de Janeiro and the north/northeast first. That's where the most late orders are.
2. Give customers more realistic delivery estimates. A late order damages the review more than a slightly longer promise would.
3. Try to win back first-time buyers, for example with a "buy again" offer after a good delivery.
4. Look after the top 20 sellers with priority support, since losing several would hurt revenue.

## How I did it

1. **Python (pandas):** loaded the 8 CSV files into MySQL and converted the date columns. See `load_olist.ipynb`.
2. **SQL (MySQL 8):** answered the six questions with joins, CTEs and window functions. See `scripts/analysis.sql`.
3. **Power BI:** built a data model with a Date table and DAX measures, then a 3-page report with navigation and a year filter.

## Other decisions

- Revenue = item price of delivered orders, excluding shipping.
- The state comparison only includes states with 500+ orders, because small states jump around too much.

## Tools

Python (pandas, SQLAlchemy) · MySQL 8 · DBeaver · Power BI (DAX, Power Query) · Jupyter

## Data

[Olist Brazilian E-Commerce Dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) on Kaggle. The CSV files aren't stored in this repo; see `data/README.md` for download instructions. The Power BI file is available on request.

## Repo structure

- `data/`: download instructions for the dataset
- `scripts/analysis.sql`: the six business questions in SQL
- `dashboard/`: dashboard screenshots
- `load_olist.ipynb`: loads the CSVs into MySQL
