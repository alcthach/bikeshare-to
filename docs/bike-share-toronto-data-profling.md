[[2022-12-29]]

---
17:37

# Data Profiling

Not sure of the business rules that need to be in place. However, I'll just form an inbox of things that I'll need to explore:

- There shouldn't be any duplicate trips
- Business logic that I could employ is that there shouldn't be any duplicate `trip_id` in the data set
- Need to investigate the distribution of `trip_duration_seconds`
	- I know that I ran into some issues or rather saw some peculiar values in this field
	- Re: I don't expect trip durations to be around 0-10 seconds long, unless the customer had initialized a trip, but decided to cancel the trip
- Have to investigate the values each value takes on 
- Just thought of what my BrainStation instructor had mentioned about EDA, just getting to know the columns and their business meaning, logic, relationships, etc. 
- I'm wondering what the difference is between EDA and data profiling, cleaning, munging, etc. 
- 