-   [**Selecting columns**](#selecting-columns)
    -   [**Selecting columns: the
        basics**](#selecting-columns-the-basics)
    -   [**Selecting columns based on partial column
        names**](#selecting-columns-based-on-partial-column-names)
    -   [**Selecting columns based on
        regex**](#selecting-columns-based-on-regex)
    -   [**Selecting columns based pre-identified
        columns**](#selecting-columns-based-pre-identified-columns)
    -   [**Selecting columns by their data
        type**](#selecting-columns-by-their-data-type)
    -   [**Selecting columns by logical
        expressions**](#selecting-columns-by-logical-expressions)
-   [**Re-ordering columns**](#re-ordering-columns)
-   [**Column names**](#column-names)
    -   [**Renaming columns**](#renaming-columns)
    -   [**Reformatting all column
        names**](#reformatting-all-column-names)
    -   [**Row names to column**](#row-names-to-column)

Data Wrangling Part 1: Basic to Advanced Ways to Select Columns

I went through the entire dplyr documentation for a talk last week about
pipes, which resulted in a few "aha!" moments. I discovered and
re-discovered a few useful functions, which I wanted to collect in a few
blog posts so I can share them with others.  
This first post will cover ordering, naming and selecting columns. The
next post will be about recoding and transforming columns, and after
that I will move on to row selection. I changed dataset versus the talk
last week to one that is built-in to R so code can be copy pasted and
experimented with easily.  
<br> All code will be presented as part of pipe even though hardly any
of them are a full pipe. I did add `glimpse()` statement to allow you to
see the columns selected in the output tibble without printing all the
data every time.

**The dataset**

    library(tidyverse)

    #built-in R dataset 
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

------------------------------------------------------------------------

**Selecting columns**
=====================

**Selecting columns: the basics**
---------------------------------

To select a few columns just add their names in the select statement.
The order in which you add them, will determine the order in which they
appear in the output.

    msleep %>%
      select(name, genus, sleep_total, awake) %>%
      glimpse()

    ## Observations: 83
    ## Variables: 4
    ## $ name        <chr> "Cheetah", "Owl monkey", "Mountain beaver", "Great...
    ## $ genus       <chr> "Acinonyx", "Aotus", "Aplodontia", "Blarina", "Bos...
    ## $ sleep_total <dbl> 12.1, 17.0, 14.4, 14.9, 4.0, 14.4, 8.7, 7.0, 10.1,...
    ## $ awake       <dbl> 11.9, 7.0, 9.6, 9.1, 20.0, 9.6, 15.3, 17.0, 13.9, ...

<br>

If you want to add a lot of columns, it can save you some typing to have
a good look at your data and see whether you can't get to your selection
by using chunks, deselecting or even deselect a column and re-add it
straight after.

To add a chunk of columns use the `start_col:end_col` syntax:

    msleep %>%
      select(name:order, sleep_total:sleep_cycle) %>%
      glimpse

    ## Observations: 83
    ## Variables: 7
    ## $ name        <chr> "Cheetah", "Owl monkey", "Mountain beaver", "Great...
    ## $ genus       <chr> "Acinonyx", "Aotus", "Aplodontia", "Blarina", "Bos...
    ## $ vore        <chr> "carni", "omni", "herbi", "omni", "herbi", "herbi"...
    ## $ order       <chr> "Carnivora", "Primates", "Rodentia", "Soricomorpha...
    ## $ sleep_total <dbl> 12.1, 17.0, 14.4, 14.9, 4.0, 14.4, 8.7, 7.0, 10.1,...
    ## $ sleep_rem   <dbl> NA, 1.8, 2.4, 2.3, 0.7, 2.2, 1.4, NA, 2.9, NA, 0.6...
    ## $ sleep_cycle <dbl> NA, NA, NA, 0.1333333, 0.6666667, 0.7666667, 0.383...

<br>

An alternative is to **deselect columns** by adding a minus sign in
front of the column name. You can also deselect chunks of columns.

    msleep %>% 
      select(-conservation, -(sleep_total:awake)) %>%
      glimpse

    ## Observations: 83
    ## Variables: 6
    ## $ name    <chr> "Cheetah", "Owl monkey", "Mountain beaver", "Greater s...
    ## $ genus   <chr> "Acinonyx", "Aotus", "Aplodontia", "Blarina", "Bos", "...
    ## $ vore    <chr> "carni", "omni", "herbi", "omni", "herbi", "herbi", "c...
    ## $ order   <chr> "Carnivora", "Primates", "Rodentia", "Soricomorpha", "...
    ## $ brainwt <dbl> NA, 0.01550, NA, 0.00029, 0.42300, NA, NA, NA, 0.07000...
    ## $ bodywt  <dbl> 50.000, 0.480, 1.350, 0.019, 600.000, 3.850, 20.490, 0...

<br>

It's even possible to deselect a whole chunk, and then re-add a column
again.  
The below sample code deselects the whole chunk from ID to pledged, but
re-adds the 'name', even though it was part of the deselected chunk.
This only works if you re-add it in the same `select()` statement.

    msleep %>%
      select(-(name:awake), conservation) %>%
      glimpse

    ## Observations: 83
    ## Variables: 3
    ## $ brainwt      <dbl> NA, 0.01550, NA, 0.00029, 0.42300, NA, NA, NA, 0....
    ## $ bodywt       <dbl> 50.000, 0.480, 1.350, 0.019, 600.000, 3.850, 20.4...
    ## $ conservation <chr> "lc", NA, "nt", "lc", "domesticated", NA, "vu", N...

<br><br>

**Selecting columns based on partial column names**
---------------------------------------------------

If you have a lot of columns with a similar structure you can use
partial matching by adding `starts_with()`, `ends_with()` or
`contains()` in your select statement depending on how you want to match
columns.

    msleep %>%
      select(name, starts_with("sleep")) %>%
      glimpse

    ## Observations: 83
    ## Variables: 4
    ## $ name        <chr> "Cheetah", "Owl monkey", "Mountain beaver", "Great...
    ## $ sleep_total <dbl> 12.1, 17.0, 14.4, 14.9, 4.0, 14.4, 8.7, 7.0, 10.1,...
    ## $ sleep_rem   <dbl> NA, 1.8, 2.4, 2.3, 0.7, 2.2, 1.4, NA, 2.9, NA, 0.6...
    ## $ sleep_cycle <dbl> NA, NA, NA, 0.1333333, 0.6666667, 0.7666667, 0.383...

    msleep %>%
      select(contains("eep"), ends_with("wt")) %>%
      glimpse

    ## Observations: 83
    ## Variables: 5
    ## $ sleep_total <dbl> 12.1, 17.0, 14.4, 14.9, 4.0, 14.4, 8.7, 7.0, 10.1,...
    ## $ sleep_rem   <dbl> NA, 1.8, 2.4, 2.3, 0.7, 2.2, 1.4, NA, 2.9, NA, 0.6...
    ## $ sleep_cycle <dbl> NA, NA, NA, 0.1333333, 0.6666667, 0.7666667, 0.383...
    ## $ brainwt     <dbl> NA, 0.01550, NA, 0.00029, 0.42300, NA, NA, NA, 0.0...
    ## $ bodywt      <dbl> 50.000, 0.480, 1.350, 0.019, 600.000, 3.850, 20.49...

<br><br>

**Selecting columns based on regex**
------------------------------------

The previous helper functions work with exact pattern matches. If you
have similar patterns that are not entirely the same you can use any
regular expression inside `matches()`.  
The below example code will add any column that contains an 'o',
followed by one or more other letters, and "er".

    #selecting based on regex
    msleep %>%
      select(matches("o.+er")) %>%
      glimpse

    ## Observations: 83
    ## Variables: 2
    ## $ order        <chr> "Carnivora", "Primates", "Rodentia", "Soricomorph...
    ## $ conservation <chr> "lc", NA, "nt", "lc", "domesticated", NA, "vu", N...

<br><br>

**Selecting columns based pre-identified columns**
--------------------------------------------------

There is another option which avoids the continuous retyping of columns
names: `one_of()`. You can set up column names upfront, and then refer
to them inside a `select()` statement by either wrapping them inside
`one_of()` or by using the `!!` operator.

    classification <- c("name", "genus", "vore", "order", "conservation")


    msleep %>%
      select(!!classification)

    ## # A tibble: 83 x 5
    ##    name                       genus       vore  order        conservation
    ##    <chr>                      <chr>       <chr> <chr>        <chr>       
    ##  1 Cheetah                    Acinonyx    carni Carnivora    lc          
    ##  2 Owl monkey                 Aotus       omni  Primates     <NA>        
    ##  3 Mountain beaver            Aplodontia  herbi Rodentia     nt          
    ##  4 Greater short-tailed shrew Blarina     omni  Soricomorpha lc          
    ##  5 Cow                        Bos         herbi Artiodactyla domesticated
    ##  6 Three-toed sloth           Bradypus    herbi Pilosa       <NA>        
    ##  7 Northern fur seal          Callorhinus carni Carnivora    vu          
    ##  8 Vesper mouse               Calomys     <NA>  Rodentia     <NA>        
    ##  9 Dog                        Canis       carni Carnivora    domesticated
    ## 10 Roe deer                   Capreolus   herbi Artiodactyla lc          
    ## # ... with 73 more rows

\`

**Selecting columns by their data type**
----------------------------------------

The `select_if` function allows you to pass functions which return
logical statements. For instance you can select all the string columns
by using `select_if(is.character)`. Similarly, you can add `is.numeric`,
`is.integer`, `is.double`, `is.logical`, `is.factor`.  
If you have data columns, you can load the `lubridate` package, and use
`is.POSIXt` or `is.Date`.

    msleep %>%
      select_if(is.numeric) %>%
      glimpse

    ## Observations: 83
    ## Variables: 6
    ## $ sleep_total <dbl> 12.1, 17.0, 14.4, 14.9, 4.0, 14.4, 8.7, 7.0, 10.1,...
    ## $ sleep_rem   <dbl> NA, 1.8, 2.4, 2.3, 0.7, 2.2, 1.4, NA, 2.9, NA, 0.6...
    ## $ sleep_cycle <dbl> NA, NA, NA, 0.1333333, 0.6666667, 0.7666667, 0.383...
    ## $ awake       <dbl> 11.9, 7.0, 9.6, 9.1, 20.0, 9.6, 15.3, 17.0, 13.9, ...
    ## $ brainwt     <dbl> NA, 0.01550, NA, 0.00029, 0.42300, NA, NA, NA, 0.0...
    ## $ bodywt      <dbl> 50.000, 0.480, 1.350, 0.019, 600.000, 3.850, 20.49...

<br>

You can also select the negation but in this case you will need to add a
tilde to ensure that you still pass a function to `select_if`.

    msleep %>%
      select_if(~!is.numeric(.)) %>%
      glimpse

    ## Observations: 83
    ## Variables: 5
    ## $ name         <chr> "Cheetah", "Owl monkey", "Mountain beaver", "Grea...
    ## $ genus        <chr> "Acinonyx", "Aotus", "Aplodontia", "Blarina", "Bo...
    ## $ vore         <chr> "carni", "omni", "herbi", "omni", "herbi", "herbi...
    ## $ order        <chr> "Carnivora", "Primates", "Rodentia", "Soricomorph...
    ## $ conservation <chr> "lc", NA, "nt", "lc", "domesticated", NA, "vu", N...

<br><br>

**Selecting columns by logical expressions**
--------------------------------------------

In fact, `select_if` allows you to select based on any logical function,
not just based on data type. It is possible to select all columns which
average is above 500 for instance. To avoid errors you do have to also
select numeric columns only, which you can do either upfront for easier
syntax, or in the same line.  
Similarly `mean > 500` is not a function in itself, so you will need to
add a tilde upfront to turn the statement into a function.

    msleep %>%
      select_if(is.numeric) %>%
      select_if(~mean(., na.rm=TRUE) > 10)

<br> or shorter:

    msleep %>%
      select_if(~is.numeric(.) & mean(., na.rm=TRUE) > 10)

    ## # A tibble: 83 x 3
    ##    sleep_total awake  bodywt
    ##          <dbl> <dbl>   <dbl>
    ##  1        12.1  11.9  50    
    ##  2        17     7     0.48 
    ##  3        14.4   9.6   1.35 
    ##  4        14.9   9.1   0.019
    ##  5         4    20   600    
    ##  6        14.4   9.6   3.85 
    ##  7         8.7  15.3  20.5  
    ##  8         7    17     0.045
    ##  9        10.1  13.9  14    
    ## 10         3    21    14.8  
    ## # ... with 73 more rows

<br>

One of the useful functions for `select_if` is `n_distinct()`, which
counts the amount of distinct values that can be found in a column.  
To return the columns that have less than 20 distinct answers for
instance you pass `~n_distinct(.) < 20` within the select\_if statement.
Given that `n_distinct(.) < 20` is not a function, you will need to put
a tilde in front.

    msleep %>%
      select_if(~n_distinct(.) < 10)

    ## # A tibble: 83 x 2
    ##    vore  conservation
    ##    <chr> <chr>       
    ##  1 carni lc          
    ##  2 omni  <NA>        
    ##  3 herbi nt          
    ##  4 omni  lc          
    ##  5 herbi domesticated
    ##  6 herbi <NA>        
    ##  7 carni vu          
    ##  8 <NA>  <NA>        
    ##  9 carni domesticated
    ## 10 herbi lc          
    ## # ... with 73 more rows

<br>

------------------------------------------------------------------------

**Re-ordering columns**
=======================

You can use the `select()` function (see below) to re-order columns. The
order in which you select them will determine the final order.

    msleep %>%
      select(conservation, sleep_total, name) %>%
      glimpse

    ## Observations: 83
    ## Variables: 3
    ## $ conservation <chr> "lc", NA, "nt", "lc", "domesticated", NA, "vu", N...
    ## $ sleep_total  <dbl> 12.1, 17.0, 14.4, 14.9, 4.0, 14.4, 8.7, 7.0, 10.1...
    ## $ name         <chr> "Cheetah", "Owl monkey", "Mountain beaver", "Grea...

<br>

If you are just moving a few columns to the front, you can use
`everything()` afterwards which will add all the remaining columns and
save a lot of typing.

    msleep %>%
      select(conservation, sleep_total, everything()) %>%
      glimpse

    ## Observations: 83
    ## Variables: 11
    ## $ conservation <chr> "lc", NA, "nt", "lc", "domesticated", NA, "vu", N...
    ## $ sleep_total  <dbl> 12.1, 17.0, 14.4, 14.9, 4.0, 14.4, 8.7, 7.0, 10.1...
    ## $ name         <chr> "Cheetah", "Owl monkey", "Mountain beaver", "Grea...
    ## $ genus        <chr> "Acinonyx", "Aotus", "Aplodontia", "Blarina", "Bo...
    ## $ vore         <chr> "carni", "omni", "herbi", "omni", "herbi", "herbi...
    ## $ order        <chr> "Carnivora", "Primates", "Rodentia", "Soricomorph...
    ## $ sleep_rem    <dbl> NA, 1.8, 2.4, 2.3, 0.7, 2.2, 1.4, NA, 2.9, NA, 0....
    ## $ sleep_cycle  <dbl> NA, NA, NA, 0.1333333, 0.6666667, 0.7666667, 0.38...
    ## $ awake        <dbl> 11.9, 7.0, 9.6, 9.1, 20.0, 9.6, 15.3, 17.0, 13.9,...
    ## $ brainwt      <dbl> NA, 0.01550, NA, 0.00029, 0.42300, NA, NA, NA, 0....
    ## $ bodywt       <dbl> 50.000, 0.480, 1.350, 0.019, 600.000, 3.850, 20.4...

<br>

------------------------------------------------------------------------

**Column names**
================

Sometimes changes are necessary to column names in itself:

**Renaming columns**
--------------------

If you will be using a `select()` statement, you can rename straight in
the `select` function.

    msleep %>%
      select(animal = name, sleep_total, extinction_threat = conservation) %>%
      glimpse

    ## Observations: 83
    ## Variables: 3
    ## $ animal            <chr> "Cheetah", "Owl monkey", "Mountain beaver", ...
    ## $ sleep_total       <dbl> 12.1, 17.0, 14.4, 14.9, 4.0, 14.4, 8.7, 7.0,...
    ## $ extinction_threat <chr> "lc", NA, "nt", "lc", "domesticated", NA, "v...

<br>

If you want to retain all columns and therefore have no `select()`
statement, you can rename by adding a `rename()` statement.

    msleep %>% 
      rename(animal = name, extinction_threat = conservation) %>%
      glimpse

    ## Observations: 83
    ## Variables: 11
    ## $ animal            <chr> "Cheetah", "Owl monkey", "Mountain beaver", ...
    ## $ genus             <chr> "Acinonyx", "Aotus", "Aplodontia", "Blarina"...
    ## $ vore              <chr> "carni", "omni", "herbi", "omni", "herbi", "...
    ## $ order             <chr> "Carnivora", "Primates", "Rodentia", "Sorico...
    ## $ extinction_threat <chr> "lc", NA, "nt", "lc", "domesticated", NA, "v...
    ## $ sleep_total       <dbl> 12.1, 17.0, 14.4, 14.9, 4.0, 14.4, 8.7, 7.0,...
    ## $ sleep_rem         <dbl> NA, 1.8, 2.4, 2.3, 0.7, 2.2, 1.4, NA, 2.9, N...
    ## $ sleep_cycle       <dbl> NA, NA, NA, 0.1333333, 0.6666667, 0.7666667,...
    ## $ awake             <dbl> 11.9, 7.0, 9.6, 9.1, 20.0, 9.6, 15.3, 17.0, ...
    ## $ brainwt           <dbl> NA, 0.01550, NA, 0.00029, 0.42300, NA, NA, N...
    ## $ bodywt            <dbl> 50.000, 0.480, 1.350, 0.019, 600.000, 3.850,...

<br><br>

**Reformatting all column names**
---------------------------------

The `select_all()` function allows changes to all columns, and takes a
function as an argument.

To get all column names in uppercase, you can use `toupper()`, similarly
you could use `tolower()`.

    msleep %>%
      select_all(toupper)

    ## # A tibble: 83 x 11
    ##    NAME   GENUS VORE  ORDER CONSERVATION SLEEP_TOTAL SLEEP_REM SLEEP_CYCLE
    ##    <chr>  <chr> <chr> <chr> <chr>              <dbl>     <dbl>       <dbl>
    ##  1 Cheet~ Acin~ carni Carn~ lc                  12.1      NA        NA    
    ##  2 Owl m~ Aotus omni  Prim~ <NA>                17         1.8      NA    
    ##  3 Mount~ Aplo~ herbi Rode~ nt                  14.4       2.4      NA    
    ##  4 Great~ Blar~ omni  Sori~ lc                  14.9       2.3       0.133
    ##  5 Cow    Bos   herbi Arti~ domesticated         4         0.7       0.667
    ##  6 Three~ Brad~ herbi Pilo~ <NA>                14.4       2.2       0.767
    ##  7 North~ Call~ carni Carn~ vu                   8.7       1.4       0.383
    ##  8 Vespe~ Calo~ <NA>  Rode~ <NA>                 7        NA        NA    
    ##  9 Dog    Canis carni Carn~ domesticated        10.1       2.9       0.333
    ## 10 Roe d~ Capr~ herbi Arti~ lc                   3        NA        NA    
    ## # ... with 73 more rows, and 3 more variables: AWAKE <dbl>, BRAINWT <dbl>,
    ## #   BODYWT <dbl>

<br>

You can go further than that by creating functions on the fly: if you
have messy column names coming from excel for instance you can replace
all white spaces with an underscore.

    #making an unclean database:
    msleep2 <- select(msleep, name, sleep_total, brainwt)
    colnames(msleep2) <- c("name", "sleep total", "brain weight")

    msleep2 %>%
      select_all(~str_replace(., " ", "_"))

    ## # A tibble: 83 x 3
    ##    name                       sleep_total brain_weight
    ##    <chr>                            <dbl>        <dbl>
    ##  1 Cheetah                           12.1     NA      
    ##  2 Owl monkey                        17        0.0155 
    ##  3 Mountain beaver                   14.4     NA      
    ##  4 Greater short-tailed shrew        14.9      0.00029
    ##  5 Cow                                4        0.423  
    ##  6 Three-toed sloth                  14.4     NA      
    ##  7 Northern fur seal                  8.7     NA      
    ##  8 Vesper mouse                       7       NA      
    ##  9 Dog                               10.1      0.07   
    ## 10 Roe deer                           3        0.0982 
    ## # ... with 73 more rows

<br><br>

**Row names to column**
-----------------------

Some dataframes have rownames that are not actually a column in itself,
like the mtcars dataset:

     mtcars %>%
       head

    ##                    mpg cyl disp  hp drat    wt  qsec vs am gear carb
    ## Mazda RX4         21.0   6  160 110 3.90 2.620 16.46  0  1    4    4
    ## Mazda RX4 Wag     21.0   6  160 110 3.90 2.875 17.02  0  1    4    4
    ## Datsun 710        22.8   4  108  93 3.85 2.320 18.61  1  1    4    1
    ## Hornet 4 Drive    21.4   6  258 110 3.08 3.215 19.44  1  0    3    1
    ## Hornet Sportabout 18.7   8  360 175 3.15 3.440 17.02  0  0    3    2
    ## Valiant           18.1   6  225 105 2.76 3.460 20.22  1  0    3    1

<br>

If you want this column to be an actual column, you can use the
`rownames_to_column()` function, and specify a new column name.

     mtcars %>%
       rownames_to_column("car_model") %>%
       head

    ##           car_model  mpg cyl disp  hp drat    wt  qsec vs am gear carb
    ## 1         Mazda RX4 21.0   6  160 110 3.90 2.620 16.46  0  1    4    4
    ## 2     Mazda RX4 Wag 21.0   6  160 110 3.90 2.875 17.02  0  1    4    4
    ## 3        Datsun 710 22.8   4  108  93 3.85 2.320 18.61  1  1    4    1
    ## 4    Hornet 4 Drive 21.4   6  258 110 3.08 3.215 19.44  1  0    3    1
    ## 5 Hornet Sportabout 18.7   8  360 175 3.15 3.440 17.02  0  0    3    2
    ## 6           Valiant 18.1   6  225 105 2.76 3.460 20.22  1  0    3    1
