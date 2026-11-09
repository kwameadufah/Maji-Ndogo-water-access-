# Maji Ndogo water access: SQL analysis and Power BI dashboard

An end-to-end analysis of a national water survey: 60,000 records on water sources, queues and well pollution, cleaned and analysed in MySQL, checked against an independent audit, and turned into a repair plan and a Power BI dashboard. I did this during the ALX Data Science program (2025) as the Maji Ndogo water integrated project.

**Skills:** SQL (MySQL: joins, CTEs, views, window functions, CASE logic), data cleaning, data auditing, Power BI

## The question

Maji Ndogo is a fictional country where many people struggle to get safe water. The president asked: which water sources are failing, how many people does that affect, and where should repair teams go first?

## What I found

| Finding | Number |
|---|---|
| People using shared taps | 43% of the population, often around 2,000 people per tap |
| People with taps at home that don't work | 14% of the population (45% of home tap users) |
| People relying on wells | 18%, and only 28% of wells are clean |
| Average queue for water | 123 minutes |
| Worst day to queue | Saturday, 246 minutes on average; Sunday is the shortest at 82 |

**The audit.** An independent auditor re-scored a sample of water sources. I joined the audit to the survey records, isolated the scores that didn't match, and traced them to individual field surveyors. Four surveyors had far more mismatches than the rest (26, 21, 17 and 7, against an average of 6). Residents' statements about these four mentioned cash payments. I flagged them for investigation.

**The repair plan.** I built a `Project_progress` table that assigns each failing source a specific fix:

- Rivers: drill wells.
- Wells contaminated with biological material: install UV filters.
- Wells contaminated with chemicals: install reverse osmosis filters.
- Shared taps with long queues: add taps, scaled to the queue length.
- Broken home taps: diagnose the local infrastructure.

## Repository

| Folder | Contents |
|---|---|
| `sql/` | The queries, in four files that follow the project's four stages: explore, clean and analyse, audit, plan |
| `notebooks/` | The full working notebook, with query results and my notes |
| `powerbi/` | The Power BI dashboard file (`.pbix`, opens in Power BI Desktop) |
| `data/` | The MySQL database dump, the auditor's report and the data dictionary |

## Run it

1. Load the database: `mysql -u root -p < data/md_water_services.sql`
2. Run the files in `sql/` in order, or open the notebook and set your own MySQL password in the connection cell.

## Data

The database, the audit file and the project brief are the synthetic Maji Ndogo materials that ALX and ExploreAI provide for training. The queries, the analysis and the repair plan are my own work.

---

Prince Adufah · [adufah.com](https://adufah.com) · [LinkedIn](https://www.linkedin.com/in/princeadufah)
