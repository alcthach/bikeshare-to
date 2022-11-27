[[2022-11-24]]

---

10:51

It's been a while since I've worked on this project. I don't have the processed csv files because I had to wipe my drive prior to installing the dual-boot on my machine. This meant I had to download the csv files from the Open Data Toronto Portal. Luckily I wrote a filename processing script to clean up and standardize the file names. From there I think I'll need to ensure that my postgresql is up and running. I'm not sure if the dual boot and upgrade to Fedora 37 did anything funky. 

So I'm going to re-install just to make sure. 

Alright, so I followed the Fedora docs for setting up postgresql server. Just needed to tidy up the databases a bit. 

I think the next step is going to be to use some of my loading scripts to send the raw data to the postgres server. 

However, I'll need to initialize the database first so that the pgfutter can do its thing. 

Looks like I might have created two separate loading scripts. One for 2017-18 data, and one for 2019-present data. 

Created a new database called `bike-share-toronto` this is going to be where my csv are loaded to or staged

Something strange is happening with the batch pgfutter loading script. I'm able to print the files that I need to load. However, I don't think the script is able to find the location of pgfutter. I need to figure out how to call pgfutter from the script. I can call it from terminal but not the script.

Alright, I'm learning to judge the progress of a day by it's own merit. Today I managed to set up my environment, do a bit of processing for the raw csv files and beginning to debug the pgfutter load csv scripts. That's more than I've done in a while. And I would say this is a lot of the work that needs to be done prior to the modelling and analytics anyways.

I have to learn that I need to function within the energy, effort, resources I have available and for today, I think that's enough for me. I don't want to feel over extended at any point because I need to consider maintaining a constant baseline of effort, focus and energy at all times. 

This is something that I have on my Notion homepage that I need to bring into practice each day...

I did enough for today.