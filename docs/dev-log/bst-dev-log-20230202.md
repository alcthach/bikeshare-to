[[2023-02-02]]

---
09:18

Just to recap on from the last session. I address the issue with the missing start and end station names. The majority of the missing values were imputed using the stations data that I pulled from the api endpoint. 

There were a small number of rows (compared to the entire data set) that were dropped. The station IDs for some of these records didn't match what was found in that stations table. It was about 4-5 stations I think? I'll have to get the exact number for the documentation I'll be writing.

I also wonder if it's because the api hasn't been updated?

Anyway, the immediate goal for today is to consolidate the `user_type` into two levels. Right now there are 4 levels. 

| user\_type | count |
| :--- | :--- |
| Annual Member | 8699993 |
| Casual | 327584 |
| Casual Member | 5997939 |
| Member | 1164784 |

Might be worth revisiting Codd's Laws to see if there's any pattern that I could employ.

I'll probably go with my initial idea of turning the field, or augmenting the table to include a boolean value field that tells the user whether or not the trip was completed by a membership holder.

The website doesn't mention anything about casual members. Which the logic is a bit strange at least to me it is. Only because there is no such thing as a casual membership. 
 
However, under the `user_type` header, the level `casual` appears to make sense. I might augment the table with a field called `is_annual_member`, the business logic is if the trip was completed by a customer that purchase an annual membership, then `is_annual_member` is `true`. If `false`, the customer did not have an active annual membership at the time that the trip had occurred. And thus can be classified as a casual user or customer.

I like that logic better actually.

Getting to writing the code now.

Something like:

``` pseudocode
for every value in `user_type`
if user_type is like "Annual.." or "member"
	then write to column is_annual_member True
else
	write to col is_annual_member False
```

This new column will need to be persisted.

Maybe something like:

``` pseudocode
alter table
create col name boolean

update table 
set new col to
	case when statement using the pseudocode above
```

Unsafe query: 'Update' statement without 'where' updates all table rows at once

``` sql
update trips_clean  
set is_annual_member =  
    case when user_type ~ '^Casual.' then FALSE  
         else true    
	 end
where trip_id = trip_id;
```

I used the logic because there was a `Member` value that was a bit ambiguous. If I used `^Annual` would have to include a conditional to cover `Member` as well. In the snippet above I save some additional lines by using `^Casual` instead.

That completes the first round of profiling, cleaning, modelling the data 🙌

---
15:28

Jumping back into things this afternoon! I'm not too sure what I want to working on at this time. However, it might help to review some of the earlier documentation to see what be outstanding, or it might lead me to some of the next steps.

Right now, I don't think the data set would be ready to hit the business user. So I might go back to some of the [[Kimball]] material to see what steps I'd want to with regards to modelling the data.

Skimming through my earlier documentation, it seems like I've covered quite a bit in terms of preparing the data.

I'll try to reacquiant myself with the data again. I've been so focused on the cleaning tasks that I've lost track of what the data looks like as a whole.

I'll likely have to clean the stations table some time in the future, but I can worry about that some other time

Actually had a logic error with the regex expression I used to consolidate the `user_type` column. `'^Casual.'` means starts with capital 'C', and has one and only one character after the 'l'. `'^Casual.?'` means one or zero of '.' It is a quantity modifier. Finally, `'^Casual.*'`, means zero or more of `'.'` AKA any character. 

Which covers both `Casual` and `Casual Member`

Outside of my high focus hours. Not going to try to force anything more. It think I'm at a good spot now. Some review on [[Kimball]]'s material would be nice just to refresh myself before modelling the data.