# Snomo-scraping: Web scraping snowmobile data with R

**DISCLAIMER: This repository is for demonstrational and educational purposes only. Please see the `LICENSE` for warranty terms. You are encouraged to review the terms of use for all websites before accessing any content.**

My home state of New York has over 10 thousand miles of snowmobile trails.[^1] On a busy winter day, it can feel like you saw just as many different types of sleds cruising past you. In the fall of 2022, one of my family members engaged my help in finding a sled that would meet their needs. Faced with an overwhelming number of options, I turned to R to help sort through some of the online data posted by snowmobile manufacturers.

This GitHub repository contains code that builds a database of snowmobile models and their technical specifications scraped from over 350 individual web pages. The work uses several packages including [`polite`](https://github.com/dmi3kno/polite) to scrape the data and [`dplyr`](https://github.com/tidyverse/dplyr) to make it look the way it should. While I am an experienced user of the [`tidyverse`](https://www.tidyverse.org/), this project marks my first forray into web scraping and [parallel computing](https://www.futureverse.org/) (so please don't judge the code too harshly  :slightly_smiling_face:). 

Due to the sensitive nature of web scraping, I have intentionally omitted any direct references to the source data. Please be respectful of all content that is not your own.

[^1]: https://nysnowmobiler.com/ride-ny-trails/ride-ny/

#### Terms of Use Links
- [Ski-Doo](https://www.ski-doo.com/us/en/legal-notice.html)
- [Polaris](https://www.polaris.com/en-us/terms/)
- [Arctic Cat (Textron)](https://www.textron.com/Legal/Site-Terms-Conditions-Terms-Use)
- [Yamaha](https://yamaha-motor.com/terms-and-conditions)

