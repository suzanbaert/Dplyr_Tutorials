-   [**Mutating columns: the basics**](#mutating-columns-the-basics)
-   [**Mutating several columns at
    once**](#mutating-several-columns-at-once)
    -   [**Mutate all**](#mutate-all)
    -   [**Mutate if**](#mutate-if)
    -   [**Mutate at to change specifc
        columns**](#mutate-at-to-change-specifc-columns)
-   [**Working with discrete columns**](#working-with-discrete-columns)
    -   [**Recoding discrete columns**](#recoding-discrete-columns)
    -   [**Creating new discrete column (two
        levels)**](#creating-new-discrete-column-two-levels)
    -   [**Creating new discrete column (multiple
        levels)**](#creating-new-discrete-column-multiple-levels)
-   [**Splitting and merging columns**](#splitting-and-merging-columns)
-   [**Bringing in columns from other data
    tables**](#bringing-in-columns-from-other-data-tables)
-   [**Spreading and gathering data**](#spreading-and-gathering-data)
-   [**Turning data into NA**](#turning-data-into-na)

This is a second post in a series of dplyr functions. The first one
covered basic and advanced ways to select, rename and reorder
columns,and can be found here.

This second one covers tools to manipulate your columns to get them the
way you want them. - content

**The data**  
As per previous blog posts, many of these functions truly shine when you
have a lot of columns, but to make it easy on people to copy paste code
and experiment, I'm using a built-in dataset:

    library(tidyverse)

    glimpse(msleep)

    ## Observations: 83
    ## Variables: 11
    ## $ name         <chr> "Cheetah", "Owl monkey", "Mountain beaver", "Grea...
    ## $ genus        <chr> "Acinonyx", "Aotus", "Aplodontia", "Blarina", "Bo...
    ## $ vore         <chr> "carni", "omni", "herbi", "omni", "herbi", "herbi...
    ## $ order        <chr> "Carnivora", "Primates", "Rodentia", "Soricomorph...
    ## $ conservation <chr> "lc", NA, "nt", "lc", "domesticated", NA, "vu", N...
    ## $ sleep_total  <dbl> 12.1, 17.0, 14.4, 14.9, 4.0, 14.4, 8.7, 7.0, 10.1...
    ## $ sleep_rem    <dbl> NA, 1.8, 2.4, 2.3, 0.7, 2.2, 1.4, NA, 2.9, NA, 0....
    ## $ sleep_cycle  <dbl> NA, NA, NA, 0.1333333, 0.6666667, 0.7666667, 0.38...
    ## $ awake        <dbl> 11.9, 7.0, 9.6, 9.1, 20.0, 9.6, 15.3, 17.0, 13.9,...
    ## $ brainwt      <dbl> NA, 0.01550, NA, 0.00029, 0.42300, NA, NA, NA, 0....
    ## $ bodywt       <dbl> 50.000, 0.480, 1.350, 0.019, 600.000, 3.850, 20.4...

<br>

**Mutating columns: the basics**
--------------------------------

You can make new columns with the `mutate()` function. The options
inside mutate are almost endless: pretty much anything that you can do
to normal vectors, can be done inside a `mutate()` function.  
Anything inside `mutate` can either be a new column (by giving mutate a
new column name), or can replace the current column (by keeping the same
column name).

One of the simplest options is a calculation based on values in other
columns. In the sample code, we're changing the sleep data from data
measured in hours to minutes.

    msleep %>%
      select(name, sleep_total) %>%
      mutate(sleep_total_min = sleep_total * 60)

    ## # A tibble: 83 x 3
    ##    name                       sleep_total sleep_total_min
    ##    <chr>                            <dbl>           <dbl>
    ##  1 Cheetah                          12.1              726
    ##  2 Owl monkey                       17.0             1020
    ##  3 Mountain beaver                  14.4              864
    ##  4 Greater short-tailed shrew       14.9              894
    ##  5 Cow                               4.00             240
    ##  6 Three-toed sloth                 14.4              864
    ##  7 Northern fur seal                 8.70             522
    ##  8 Vesper mouse                      7.00             420
    ##  9 Dog                              10.1              606
    ## 10 Roe deer                          3.00             180
    ## # ... with 73 more rows

New columns can be made with aggregate functions such as average,
median, max, min, sd, ...  
The sample code makes two new columns: one showing the difference of
each row versus the average sleep time, and one showing the difference
versus the animal with the least sleep.

    msleep %>%
      select(name, sleep_total) %>%
      mutate(sleep_total_vs_AVG = sleep_total - round(mean(sleep_total), 1),
             sleep_total_vs_MIN = sleep_total - min(sleep_total))

    ## # A tibble: 83 x 4
    ##    name                   sleep_total sleep_total_vs_AVG sleep_total_vs_M~
    ##    <chr>                        <dbl>              <dbl>             <dbl>
    ##  1 Cheetah                      12.1               1.70              10.2 
    ##  2 Owl monkey                   17.0               6.60              15.1 
    ##  3 Mountain beaver              14.4               4.00              12.5 
    ##  4 Greater short-tailed ~       14.9               4.50              13.0 
    ##  5 Cow                           4.00             -6.40               2.10
    ##  6 Three-toed sloth             14.4               4.00              12.5 
    ##  7 Northern fur seal             8.70             -1.70               6.80
    ##  8 Vesper mouse                  7.00             -3.40               5.10
    ##  9 Dog                          10.1              -0.300              8.20
    ## 10 Roe deer                      3.00             -7.40               1.10
    ## # ... with 73 more rows

In the below comments, Steve asked about aggregate functions across
columns. These functions by nature will want to summarise a column (like
shown above), if however you want to `sum()` or `mean()` across columns,
you might run into errors or absurd answers. In these cases you either
can revert to actually spelling out the arithmetics:
`mutate(average = (sleep_rem + sleep_cycle) / 2)` or you have to add a
special instruction to the pipe that it should perform these aggregate
functions not on the entire column, but by row:

    #alternative to using the actual arithmetics:
    msleep %>% 
      select(name, contains("sleep")) %>% 
      rowwise() %>% 
      mutate(avg = mean(c(sleep_rem, sleep_cycle)))

    ## Source: local data frame [83 x 5]
    ## Groups: <by row>
    ## 
    ## # A tibble: 83 x 5
    ##    name                       sleep_total sleep_rem sleep_cycle    avg
    ##    <chr>                            <dbl>     <dbl>       <dbl>  <dbl>
    ##  1 Cheetah                          12.1     NA          NA     NA    
    ##  2 Owl monkey                       17.0      1.80       NA     NA    
    ##  3 Mountain beaver                  14.4      2.40       NA     NA    
    ##  4 Greater short-tailed shrew       14.9      2.30        0.133  1.22 
    ##  5 Cow                               4.00     0.700       0.667  0.683
    ##  6 Three-toed sloth                 14.4      2.20        0.767  1.48 
    ##  7 Northern fur seal                 8.70     1.40        0.383  0.892
    ##  8 Vesper mouse                      7.00    NA          NA     NA    
    ##  9 Dog                              10.1      2.90        0.333  1.62 
    ## 10 Roe deer                          3.00    NA          NA     NA    
    ## # ... with 73 more rows

The `ifelse()` function deserves a special mention because it is
particularly useful if you don't want to mutate the whole column in the
same way. With `ifelse()`, you first specify a logical statement,
afterwards what needs to happen if the statement returns `TRUE`, and
lastly what needs to happen if it's `FALSE`.

Imagine that we have a database with two large values which we assume
are typos or measurement errors, and we want to exclude them. The below
code will take any `brainwt` value above 4 and return NA. In this case,
the code won't change for anything below 4.

    msleep %>%
      select(name, brainwt) %>%
      mutate(brainwt2 = ifelse(brainwt > 4, NA, brainwt)) %>%
      arrange(desc(brainwt))

    ## # A tibble: 83 x 3
    ##    name             brainwt brainwt2
    ##    <chr>              <dbl>    <dbl>
    ##  1 African elephant   5.71    NA    
    ##  2 Asian elephant     4.60    NA    
    ##  3 Human              1.32     1.32 
    ##  4 Horse              0.655    0.655
    ##  5 Chimpanzee         0.440    0.440
    ##  6 Cow                0.423    0.423
    ##  7 Donkey             0.419    0.419
    ##  8 Gray seal          0.325    0.325
    ##  9 Baboon             0.180    0.180
    ## 10 Pig                0.180    0.180
    ## # ... with 73 more rows

You can also mutate string columns with stringr's `str_extract()`
function in combination with any character or regex patterns.  
The sample code will return the last word of the animal name and makes
it lower case.

    msleep %>%
      select(name) %>%
      mutate(name_last_word = tolower(str_extract(name, pattern = "\\w+$")))

    ## # A tibble: 83 x 2
    ##    name                       name_last_word
    ##    <chr>                      <chr>         
    ##  1 Cheetah                    cheetah       
    ##  2 Owl monkey                 monkey        
    ##  3 Mountain beaver            beaver        
    ##  4 Greater short-tailed shrew shrew         
    ##  5 Cow                        cow           
    ##  6 Three-toed sloth           sloth         
    ##  7 Northern fur seal          seal          
    ##  8 Vesper mouse               mouse         
    ##  9 Dog                        dog           
    ## 10 Roe deer                   deer          
    ## # ... with 73 more rows

<br>

**Mutating several columns at once**
------------------------------------

This is where the magic really happens. Just like with the `select()`
functions in part 1, there are variants to `mutate()`:

-   `mutate_all()` will mutate all columns based on your further
    instructions
-   `mutate_if()` first requires a function that returns a boolean to
    select columns. If that is true, the summary instructions will be
    followed on those variables.
-   `mutate_at()` requires you to specify columns inside a `vars()`
    argument for which the summary will be done.

### **Mutate all**

The `mutate_all()` version is the easiest to understand, and pretty
nifty when cleaning your data. You just pass an action (in the form of a
function) that you want to apply across all columns.

Something easy to start with: turning all the data to lower case:

    msleep %>%
      mutate_all(tolower)

    ## # A tibble: 83 x 11
    ##    name   genus vore  order conservation sleep_total sleep_rem sleep_cycle
    ##    <chr>  <chr> <chr> <chr> <chr>        <chr>       <chr>     <chr>      
    ##  1 cheet~ acin~ carni carn~ lc           12.1        <NA>      <NA>       
    ##  2 owl m~ aotus omni  prim~ <NA>         17          1.8       <NA>       
    ##  3 mount~ aplo~ herbi rode~ nt           14.4        2.4       <NA>       
    ##  4 great~ blar~ omni  sori~ lc           14.9        2.3       0.133333333
    ##  5 cow    bos   herbi arti~ domesticated 4           0.7       0.666666667
    ##  6 three~ brad~ herbi pilo~ <NA>         14.4        2.2       0.766666667
    ##  7 north~ call~ carni carn~ vu           8.7         1.4       0.383333333
    ##  8 vespe~ calo~ <NA>  rode~ <NA>         7           <NA>      <NA>       
    ##  9 dog    canis carni carn~ domesticated 10.1        2.9       0.333333333
    ## 10 roe d~ capr~ herbi arti~ lc           3           <NA>      <NA>       
    ## # ... with 73 more rows, and 3 more variables: awake <chr>, brainwt <chr>,
    ## #   bodywt <chr>

But I've also used it to trim whitespaces into an entire table without
issues using: `mutate_all(str_trim)`.  
Or when scraping the web, I've often had plenty off empty spaces and
many `\n` signs across the data.

I'm first going to use `mutate_all()` to screw things up:

    msleep_ohno <- msleep %>%
      mutate_all(~paste(., "  /n  "))

    msleep_ohno[,1:4]

    ## # A tibble: 83 x 4
    ##    name                                genus                vore    order 
    ##    <chr>                               <chr>                <chr>   <chr> 
    ##  1 "Cheetah   /n  "                    "Acinonyx   /n  "    "carni~ "Carn~
    ##  2 "Owl monkey   /n  "                 "Aotus   /n  "       "omni ~ "Prim~
    ##  3 "Mountain beaver   /n  "            "Aplodontia   /n  "  "herbi~ "Rode~
    ##  4 "Greater short-tailed shrew   /n  " "Blarina   /n  "     "omni ~ "Sori~
    ##  5 "Cow   /n  "                        "Bos   /n  "         "herbi~ "Arti~
    ##  6 "Three-toed sloth   /n  "           "Bradypus   /n  "    "herbi~ "Pilo~
    ##  7 "Northern fur seal   /n  "          "Callorhinus   /n  " "carni~ "Carn~
    ##  8 "Vesper mouse   /n  "               "Calomys   /n  "     "NA   ~ "Rode~
    ##  9 "Dog   /n  "                        "Canis   /n  "       "carni~ "Carn~
    ## 10 "Roe deer   /n  "                   "Capreolus   /n  "   "herbi~ "Arti~
    ## # ... with 73 more rows

Let's clean it up again:  
In this code I am assume that not all values show the same amount of
extra white spaces as is often the case with parsed data: it frst
removes all extra white spaces and then removes any `/n`.

    msleep_corr <- msleep_ohno %>%
      mutate_all(~str_replace_all(., "/n", "")) %>%
      mutate_all(str_trim)

    msleep_corr[,1:4]

    ## # A tibble: 83 x 4
    ##    name                       genus       vore  order       
    ##    <chr>                      <chr>       <chr> <chr>       
    ##  1 Cheetah                    Acinonyx    carni Carnivora   
    ##  2 Owl monkey                 Aotus       omni  Primates    
    ##  3 Mountain beaver            Aplodontia  herbi Rodentia    
    ##  4 Greater short-tailed shrew Blarina     omni  Soricomorpha
    ##  5 Cow                        Bos         herbi Artiodactyla
    ##  6 Three-toed sloth           Bradypus    herbi Pilosa      
    ##  7 Northern fur seal          Callorhinus carni Carnivora   
    ##  8 Vesper mouse               Calomys     NA    Rodentia    
    ##  9 Dog                        Canis       carni Carnivora   
    ## 10 Roe deer                   Capreolus   herbi Artiodactyla
    ## # ... with 73 more rows

The mutating action needs to be a function: in many cases you can pass
the function name without the brackets, but in some cases you need
arguments, or you want to combine elements in which case you have some
options: either you makea function upfront (useful if it's longer), or
you make a function on the fly by wrapping it inside `funs()` or via a
tilde.

The below regex-based mutation requires a function on the fly. You can
either use `~str_replace_all(., "[aeiou]", "")` or
`funs(str_replace_all(., "[aeiou]", ""))`. When making a function on the
fly, you need to refer to the value you are replacing: which is what the
`.` refers to.

The sample code will remove any vowels:

    msleep %>%
      select(name:sleep_total) %>%
      mutate_all(~str_replace_all(., "[aeiou]", ""))

    ## # A tibble: 83 x 6
    ##    name               genus   vore  order    conservation sleep_total
    ##    <chr>              <chr>   <chr> <chr>    <chr>        <chr>      
    ##  1 Chth               Acnnyx  crn   Crnvr    lc           12.1       
    ##  2 Owl mnky           Ats     mn    Prmts    <NA>         17         
    ##  3 Mntn bvr           Apldnt  hrb   Rdnt     nt           14.4       
    ##  4 Grtr shrt-tld shrw Blrn    mn    Srcmrph  lc           14.9       
    ##  5 Cw                 Bs      hrb   Artdctyl dmstctd      4          
    ##  6 Thr-td slth        Brdyps  hrb   Pls      <NA>         14.4       
    ##  7 Nrthrn fr sl       Cllrhns crn   Crnvr    v            8.7        
    ##  8 Vspr ms            Clmys   <NA>  Rdnt     <NA>         7          
    ##  9 Dg                 Cns     crn   Crnvr    dmstctd      10.1       
    ## 10 R dr               Cprls   hrb   Artdctyl lc           3          
    ## # ... with 73 more rows

### **Mutate if**

Not all cleaning functions can be done with `mutate_all()`. Trying to
round your data will lead to an error if you have both numerical and
character columns.

    msleep %>%
      mutate_all(round)

`Error in mutate_impl(.data, dots) : Evaluation error: non-numeric argument to mathematical function.`

In these cases we have to add the condition that columns need to be
numeric before giving `round()` instructions:

By using `mutate_if()` we need two arguments inside a pipe:

-   First it needs information about the columns you want it to
    consider. This information needs to be a function that returns a
    boolean value. The easiest cases are functions like `is.numeric`,
    `is.integer`, `is.double`, `is.logical`, `is.factor`,
    `lubridate::is.POSIXt` or `lubridate::is.Date`.

-   Secondly, it needs instructions about the mutation in the form of a
    function. If needed, use a tilde or `funs()` before (see above).

<!-- -->

    msleep %>%
      select(name, sleep_total:bodywt) %>%
      mutate_if(is.numeric, round)

    ## # A tibble: 83 x 7
    ##    name             sleep_total sleep_rem sleep_cycle awake brainwt bodywt
    ##    <chr>                  <dbl>     <dbl>       <dbl> <dbl>   <dbl>  <dbl>
    ##  1 Cheetah                12.0      NA          NA    12.0       NA  50.0 
    ##  2 Owl monkey             17.0       2.00       NA     7.00       0   0   
    ##  3 Mountain beaver        14.0       2.00       NA    10.0       NA   1.00
    ##  4 Greater short-t~       15.0       2.00        0     9.00       0   0   
    ##  5 Cow                     4.00      1.00        1.00 20.0        0 600   
    ##  6 Three-toed sloth       14.0       2.00        1.00 10.0       NA   4.00
    ##  7 Northern fur se~        9.00      1.00        0    15.0       NA  20.0 
    ##  8 Vesper mouse            7.00     NA          NA    17.0       NA   0   
    ##  9 Dog                    10.0       3.00        0    14.0        0  14.0 
    ## 10 Roe deer                3.00     NA          NA    21.0        0  15.0 
    ## # ... with 73 more rows

### **Mutate at to change specifc columns**

By using `mutate_at()` we need two arguments inside a pipe:

-   First it needs information about the columns you want it to
    consider. In this case you can wrap any selection of columns (using
    all the options possible inside a `select()` function) and wrap it
    inside `vars()`.

-   Secondly, it needs instructions about the mutation in the form of a
    function. If needed, use a tilde or `funs()` before (see above).

All sleep-measuring columns are in hours. If I want those in minutes, I
can use `mutate_at()` and wrap all 'sleep' containing columns inside
`vars()`. Secondly, I make a function in the fly to multiple every value
by 60.  
The sample code shows that in this case all `sleep` columns have been
changed into minutes, but `awake` did not.

    msleep %>%
      select(name, sleep_total:awake) %>%
      mutate_at(vars(contains("sleep")), ~(.*60)) 

    ## # A tibble: 83 x 5
    ##    name                       sleep_total sleep_rem sleep_cycle awake
    ##    <chr>                            <dbl>     <dbl>       <dbl> <dbl>
    ##  1 Cheetah                            726      NA         NA    11.9 
    ##  2 Owl monkey                        1020     108         NA     7.00
    ##  3 Mountain beaver                    864     144         NA     9.60
    ##  4 Greater short-tailed shrew         894     138          8.00  9.10
    ##  5 Cow                                240      42.0       40.0  20.0 
    ##  6 Three-toed sloth                   864     132         46.0   9.60
    ##  7 Northern fur seal                  522      84.0       23.0  15.3 
    ##  8 Vesper mouse                       420      NA         NA    17.0 
    ##  9 Dog                                606     174         20.0  13.9 
    ## 10 Roe deer                           180      NA         NA    21.0 
    ## # ... with 73 more rows

<br>

**Working with discrete columns**
---------------------------------

### **Recoding discrete columns**

To rename or reorganize current discrete columns, you can use `recode()`
inside a `mutate()` statement: this enables you to change the current
naming, or to group current levels into less levels. The `.default`
refers to anything that isn't covered by the before groups with the
exception of NA. You can change NA into something other than NA by
adding a `.missing` argument if you want (see next sample code).

    msleep %>%
      mutate(conservation2 = recode(conservation,
                            "en" = "Endangered",
                            "lc" = "Least_Concern",
                            "domesticated" = "Least_Concern",
                            .default = "other")) %>%
      count(conservation2)

    ## # A tibble: 4 x 2
    ##   conservation2     n
    ##   <chr>         <int>
    ## 1 Endangered        4
    ## 2 Least_Concern    37
    ## 3 other            13
    ## 4 <NA>             29

A special version exists to return a factor: `recode_factor()`. By
default the `.ordered` argument is `FALSE`. To return an ordered factor
set the argument to `TRUE`:

    msleep %>%
      mutate(conservation2 = recode_factor(conservation,
                            "en" = "Endangered",
                            "lc" = "Least_Concern",
                            "domesticated" = "Least_Concern",
                            .default = "other",
                            .missing = "no data",
                            .ordered = TRUE)) %>%
      count(conservation2)

    ## # A tibble: 4 x 2
    ##   conservation2     n
    ##   <ord>         <int>
    ## 1 Endangered        4
    ## 2 Least_Concern    37
    ## 3 other            13
    ## 4 no data          29

<br>

### **Creating new discrete column (two levels)**

The `ifelse()` statement can be used to turn a numeric column into a
discrete one. As mentioned above, `ifelse()` takes a logical expression,
then what to do if the expression returns `TRUE` and lastly what to do
when it returns `FALSE`.  
The sample code will divide the current measure `sleep_total` into a
discrete "long" or "short" sleeper.

    msleep %>%
      select(name, sleep_total) %>%
      mutate(sleep_time = ifelse(sleep_total > 10, "long", "short")) 

    ## # A tibble: 83 x 3
    ##    name                       sleep_total sleep_time
    ##    <chr>                            <dbl> <chr>     
    ##  1 Cheetah                          12.1  long      
    ##  2 Owl monkey                       17.0  long      
    ##  3 Mountain beaver                  14.4  long      
    ##  4 Greater short-tailed shrew       14.9  long      
    ##  5 Cow                               4.00 short     
    ##  6 Three-toed sloth                 14.4  long      
    ##  7 Northern fur seal                 8.70 short     
    ##  8 Vesper mouse                      7.00 short     
    ##  9 Dog                              10.1  long      
    ## 10 Roe deer                          3.00 short     
    ## # ... with 73 more rows

<br>

### **Creating new discrete column (multiple levels)**

The `ifelse()` can be nested but if you want more than two levels, but
it might be even easier to use `case_when()` which allows as many
statements as you like and is easier to read than many nested `ifelse`
statements.  
The arguments are evaluated in order, so only the rows where the first
statement is not true will continue to be evaluated for the next
statement. For everything that is left at the end just use the
`TRUE ~ "newname"`.  
Unfortunately there seems to be no easy way to get `case_when()` to
return an ordered factor, so you will need to to do that yourself
afterwards, either by using `forcats::fct_relevel()`, or just with a
`factor()` function. If you have a lot of levels I would advice to make
a levels vector upfront to avoid cluttering the piple too much.

    msleep %>%
      select(name, sleep_total) %>%
      mutate(sleep_total_discr = case_when(
        sleep_total > 13 ~ "very long",
        sleep_total > 10 ~ "long",
        sleep_total > 7 ~ "limited",
        TRUE ~ "short")) %>%
      mutate(sleep_total_discr = factor(sleep_total_discr, 
                                        levels = c("short", "limited", 
                                                   "long", "very long")))

    ## # A tibble: 83 x 3
    ##    name                       sleep_total sleep_total_discr
    ##    <chr>                            <dbl> <fct>            
    ##  1 Cheetah                          12.1  long             
    ##  2 Owl monkey                       17.0  very long        
    ##  3 Mountain beaver                  14.4  very long        
    ##  4 Greater short-tailed shrew       14.9  very long        
    ##  5 Cow                               4.00 short            
    ##  6 Three-toed sloth                 14.4  very long        
    ##  7 Northern fur seal                 8.70 limited          
    ##  8 Vesper mouse                      7.00 short            
    ##  9 Dog                              10.1  long             
    ## 10 Roe deer                          3.00 short            
    ## # ... with 73 more rows

The `case_when()` function does not only work inside a column, but can
be used for grouping across columns:

    msleep %>%
      mutate(silly_groups = case_when(
        brainwt < 0.001 ~ "light_headed",
        sleep_total > 10 ~ "lazy_sleeper",
        is.na(sleep_rem) ~ "absent_rem",
        TRUE ~ "other")) %>%
      count(silly_groups)

    ## # A tibble: 4 x 2
    ##   silly_groups     n
    ##   <chr>        <int>
    ## 1 absent_rem       8
    ## 2 lazy_sleeper    39
    ## 3 light_headed     6
    ## 4 other           30

<br>

**Splitting and merging columns**
---------------------------------

Take for example this dataset

    (conservation_expl <- read_csv("conservation_explanation.csv"))

    ## # A tibble: 11 x 1
    ##    `conservation abbreviation`                  
    ##    <chr>                                        
    ##  1 EX = Extinct                                 
    ##  2 EW = Extinct in the wild                     
    ##  3 CR = Critically Endangered                   
    ##  4 EN = Endangered                              
    ##  5 VU = Vulnerable                              
    ##  6 NT = Near Threatened                         
    ##  7 LC = Least Concern                           
    ##  8 DD = Data deficient                          
    ##  9 NE = Not evaluated                           
    ## 10 PE = Probably extinct (informal)             
    ## 11 PEW = Probably extinct in the wild (informal)

You can unmerge any columns by using tidyr's `separate()` function. To
do this, you have to specify the column to be splitted, followed by the
new column names, and which seperator it has to look for.  
The sample code shows seperating into two columns based on '=' as a
separator.

    (conservation_table <- conservation_expl %>%
      separate(`conservation abbreviation`, 
               into = c("abbreviation", "description"), sep = " = "))

    ## # A tibble: 11 x 2
    ##    abbreviation description                            
    ##  * <chr>        <chr>                                  
    ##  1 EX           Extinct                                
    ##  2 EW           Extinct in the wild                    
    ##  3 CR           Critically Endangered                  
    ##  4 EN           Endangered                             
    ##  5 VU           Vulnerable                             
    ##  6 NT           Near Threatened                        
    ##  7 LC           Least Concern                          
    ##  8 DD           Data deficient                         
    ##  9 NE           Not evaluated                          
    ## 10 PE           Probably extinct (informal)            
    ## 11 PEW          Probably extinct in the wild (informal)

The opposite is tidyr's `unite()` function. You specify the new column
name, and then the columns to be united, and lastly what seperator you
want to use.

    conservation_table %>%
      unite(united_col, abbreviation, description, sep=": ")

    ## # A tibble: 11 x 1
    ##    united_col                                  
    ##  * <chr>                                       
    ##  1 EX: Extinct                                 
    ##  2 EW: Extinct in the wild                     
    ##  3 CR: Critically Endangered                   
    ##  4 EN: Endangered                              
    ##  5 VU: Vulnerable                              
    ##  6 NT: Near Threatened                         
    ##  7 LC: Least Concern                           
    ##  8 DD: Data deficient                          
    ##  9 NE: Not evaluated                           
    ## 10 PE: Probably extinct (informal)             
    ## 11 PEW: Probably extinct in the wild (informal)

<br>

**Bringing in columns from other data tables**
----------------------------------------------

If you want to add information from another table, you can use the
joining functions from `dplyr`. The msleep data contains abbreviations
for conservation but if you are not familiar with the topic you might
need the description we used in the section above inside the msleep
data.

Joins would be a chapter in itself, but in this particular case you
would do a `left_join()`, i.e. keeping my main table (on the left), and
adding columns from another one to the right. In the `by =` statement
you specify which colums are the same, so the join knows what to add
where.  
The sample code will add the description of the different conservation
states into our main `msleep` table. The main data contained an extra
`domisticated` label which i wanted to keep. This is done in the last
line of the table with an `ifelse()`.

    msleep %>%
      select(name, conservation) %>%
      mutate(conservation = toupper(conservation)) %>%
      left_join(conservation_table, by = c("conservation" = "abbreviation")) %>%
      mutate(description = ifelse(is.na(description), conservation, description))

    ## # A tibble: 83 x 3
    ##    name                       conservation description    
    ##    <chr>                      <chr>        <chr>          
    ##  1 Cheetah                    LC           Least Concern  
    ##  2 Owl monkey                 <NA>         <NA>           
    ##  3 Mountain beaver            NT           Near Threatened
    ##  4 Greater short-tailed shrew LC           Least Concern  
    ##  5 Cow                        DOMESTICATED DOMESTICATED   
    ##  6 Three-toed sloth           <NA>         <NA>           
    ##  7 Northern fur seal          VU           Vulnerable     
    ##  8 Vesper mouse               <NA>         <NA>           
    ##  9 Dog                        DOMESTICATED DOMESTICATED   
    ## 10 Roe deer                   LC           Least Concern  
    ## # ... with 73 more rows

<br>

**Spreading and gathering data**
--------------------------------

The `gather()` function will gather up many columns into one. In this
case, we have 3 columns that describe a time measure. For some analysis
and graphs, it might be necessary to get them all into one.  
The `gather` function needs you to give a name ("key") for the new
descriptive column, and a another name ("value") for the value column.
The columns that you don't want to gather need to be deselected at the
end. In the sample code I'm deselecting the column `name`.

    msleep %>%
      select(name, contains("sleep")) %>%
      gather(key = "sleep_measure", value = "time", -name)

    ## # A tibble: 249 x 3
    ##    name                       sleep_measure  time
    ##    <chr>                      <chr>         <dbl>
    ##  1 Cheetah                    sleep_total   12.1 
    ##  2 Owl monkey                 sleep_total   17.0 
    ##  3 Mountain beaver            sleep_total   14.4 
    ##  4 Greater short-tailed shrew sleep_total   14.9 
    ##  5 Cow                        sleep_total    4.00
    ##  6 Three-toed sloth           sleep_total   14.4 
    ##  7 Northern fur seal          sleep_total    8.70
    ##  8 Vesper mouse               sleep_total    7.00
    ##  9 Dog                        sleep_total   10.1 
    ## 10 Roe deer                   sleep_total    3.00
    ## # ... with 239 more rows

A useful attribute in gathering is the `factor_key` argument which is
`FALSE`by default. In the previous example the new column
`sleep_measure` is a character vector. If you are going to summarise or
plot afterwards, that column will be ordered alphabetically.  
If you want to preserve the original order, add `factor_key = TRUE`
which will make the new column an ordered factor.

    (msleep_g <- msleep %>%
      select(name, contains("sleep")) %>%
      gather(key = "sleep_measure", value = "time", -name, factor_key = TRUE))

    ## # A tibble: 249 x 3
    ##    name                       sleep_measure  time
    ##    <chr>                      <fct>         <dbl>
    ##  1 Cheetah                    sleep_total   12.1 
    ##  2 Owl monkey                 sleep_total   17.0 
    ##  3 Mountain beaver            sleep_total   14.4 
    ##  4 Greater short-tailed shrew sleep_total   14.9 
    ##  5 Cow                        sleep_total    4.00
    ##  6 Three-toed sloth           sleep_total   14.4 
    ##  7 Northern fur seal          sleep_total    8.70
    ##  8 Vesper mouse               sleep_total    7.00
    ##  9 Dog                        sleep_total   10.1 
    ## 10 Roe deer                   sleep_total    3.00
    ## # ... with 239 more rows

The opposite of gathering is spreading. Spread will take one column and
make multiple columns out of it. If you would have started with the
previous column, you could get the differrent sleep measures in
different columns:

    msleep_g %>%
      spread(sleep_measure, time)

    ## # A tibble: 83 x 4
    ##    name                      sleep_total sleep_rem sleep_cycle
    ##  * <chr>                           <dbl>     <dbl>       <dbl>
    ##  1 African elephant                 3.30     NA         NA    
    ##  2 African giant pouched rat        8.30      2.00      NA    
    ##  3 African striped mouse            8.70     NA         NA    
    ##  4 Arctic fox                      12.5      NA         NA    
    ##  5 Arctic ground squirrel          16.6      NA         NA    
    ##  6 Asian elephant                   3.90     NA         NA    
    ##  7 Baboon                           9.40      1.00       0.667
    ##  8 Big brown bat                   19.7       3.90       0.117
    ##  9 Bottle-nosed dolphin             5.20     NA         NA    
    ## 10 Brazilian tapir                  4.40      1.00       0.900
    ## # ... with 73 more rows

**Turning data into NA**
------------------------

The function `na_if()` turns particular values into `NA`. In most cases
the command probably be `na_if("")` (i.e turn an empty string into NA),
but in principle you can do anything.

The same code will turn any value that reads "omni" into NA

    msleep %>%
      select(name:order) %>%
      na_if("omni")

    ## # A tibble: 83 x 4
    ##    name                       genus       vore  order       
    ##    <chr>                      <chr>       <chr> <chr>       
    ##  1 Cheetah                    Acinonyx    carni Carnivora   
    ##  2 Owl monkey                 Aotus       <NA>  Primates    
    ##  3 Mountain beaver            Aplodontia  herbi Rodentia    
    ##  4 Greater short-tailed shrew Blarina     <NA>  Soricomorpha
    ##  5 Cow                        Bos         herbi Artiodactyla
    ##  6 Three-toed sloth           Bradypus    herbi Pilosa      
    ##  7 Northern fur seal          Callorhinus carni Carnivora   
    ##  8 Vesper mouse               Calomys     <NA>  Rodentia    
    ##  9 Dog                        Canis       carni Carnivora   
    ## 10 Roe deer                   Capreolus   herbi Artiodactyla
    ## # ... with 73 more rows
