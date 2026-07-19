# SLA-Breach-Risk-Cost-Impact-Analysis-SQL-and-Power-BI

1. Project Title:

   SLA Breach Risk & Cost Impact Analysis

2. Project Overview:

    This project analyzes Service Level Agreement (SLA) performance across e-commerce order data to identify delivery delays, quantify their financial            impact, and uncover the operational root causes behind SLA breaches. Using SQL and Power BI, the project converts raw transactional data into actionable      insights that help businesses proactively manage delivery risk, reduce delay-related costs, and improve customer experience. The analysis focuses not         only on how often SLA breaches occur, but where, why, and at what cost — enabling data-driven decision-making for operations, logistics, and seller           management teams.

3. Short Description:

    An end-to-end analytics project that evaluates SLA breach rates, delay duration, and financial impact across product categories, seller states, and time      periods, supported by an interactive Power BI dashboard designed for operational monitoring and root-cause analysis.

4. Project Goals:

    • Measure overall SLA performance and identify breach patterns
 
    • Quantify the financial impact of delivery delays
 
    • Detect high-risk product categories and seller regions
  
    • Enable proactive risk monitoring for emerging problem areas
 
    • Translate data insights into actionable operational recommendations

5. Key KPIs Showcased:
 
   • Total Orders Analyzed
 
   • SLA Breach Rate (%)

   • SLA Breached Orders (Count)
 
   • SLA Variance (%) — actual breach rate vs. a defined 5% target
  
   • Average Delay (Days) for Breached Orders

   • Total Delay Cost (₹)

   • SLA Risk Score — a combined frequency × severity metric used to rank seller-state risk
  
6. Tools & Technologies:
 
   •	SQL (PostgreSQL): Schema design, data cleaning, joins, aggregations, view-based data modeling, SLA breach identification, KPI calculation

    •   Power BI: Data modeling, DAX measures, interactive dashboards, slicers, drill-through, and root-cause visual analytics

8. How This Project Helps Businesses:

   • Operational Risk Reduction: Identifies delivery stages and regions contributing most to SLA failures
 
   • Cost Optimization: Highlights high-cost delay drivers to prioritize corrective actions

    • Proactive Monitoring: Flags emerging high-risk seller states (50–500 order volume) before they scale into larger problems

   • Performance Management: Enables targeted seller- and category-level interventions, distinguishing high-volume issues from high-severity ones
 
   • Decision Support: Converts complex operational data into executive-ready insights
  
8. Business Insights:
 
   •	6.77% of delivered orders breached SLA, with an average delay of 10.62 days among breached orders — indicating material last-mile delivery                    inefficiencies rather than marginal slippage.

    • Estimated total delay-cost impact was ₹257.77K, modeled using an assumed 2%-of-order-value-per-day-of-delay penalty rate (see Methodology & Assumptions       below).

    • 10+ day delays formed the single largest breach-duration bucket (2.1K of ~6.5K breached orders), with breach volume increasing alongside delay severity       — a pattern indicating systemic fulfillment/last-mile bottlenecks rather than random operational variance.

    • SP (São Paulo) accounted for the largest share of both order volume and total delay cost, while BA — despite far lower volume — had the highest average       delay per breach (14.89 days), showing that the biggest total-cost state and the most severe per-order failures aren't always the same state.
 
   • Several low-volume seller states (50–500 orders), such as MA (19.07% breach rate), showed high SLA Risk Scores — early-warning signals worth monitoring       before order volume scales further.

10. Methodology & Assumptions (Transparency Notes)

     This project makes two explicit, stated assumptions rather than presenting modeled figures as measured facts:


    Delay cost model: Since the dataset does not include actual refund, penalty, or support-cost data, delay cost is estimated as order value × 2% × days         late, applied only to breached orders. This is a directional proxy for real-world cost (refunds, support escalations, retention risk), not an audited         financial figure.

    SLA target: The 5% SLA breach-rate target used in SLA Variance % is an assumed business goal for illustrative benchmarking, not a value derived from the      dataset itself.

    Data grain: Cost and category/seller attribution are calculated at the order level. Where an order contains multiple line items, the highest-value item       is used to represent the order's category and seller for attribution purposes, to avoid double-counting order-level cost across multiple items.

10. Files in This Repository

    sla_analysis_final.sql — full SQL build: schema, data cleaning, views, and analysis queries

    SLA_Breach_Cost_Impact_powerbi.pbix — interactive Power BI dashboard (2 pages: SLA Performance Overview, SLA Root Cause & Cost Drivers)

    Dataset source: Olist Brazilian E-Commerce Public Dataset (Kaggle)

11.Dashboard Preview

   Page 1 — SLA Performance Overview: headline KPIs, breach-driving categories, monthly breach trend, and delay-duration distribution.

   Page 2 — SLA Root Cause & Cost Drivers: seller-state breakdown, high-risk customer states, cost-per-breach by category, and an early-warning table for emerging high-risk, lower-volume states.





