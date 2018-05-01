# 3: Basic and more advanced ways to filter rows

Content:


-   [**Basic row filters**](#basic-row-filters)
    -   [**Filtering rows based on a numeric
        variable**](#filtering-rows-based-on-a-numeric-variable)
    -   [**Filtering based on a exact character variable
        matches**](#filtering-based-on-a-exact-character-variable-matches)
    -   [**Filtering rows based on
        regex**](#filtering-rows-based-on-regex)
    -   [**Filtering based on multiple
        conditions**](#filtering-based-on-multiple-conditions)
    -   [**Filtering out empty rows**](#filtering-out-empty-rows)
-   [**Filtering across multiple
    columns**](#filtering-across-multiple-columns)
    -   [**Filter\_all**](#filter_all)
    -   [**Filter\_if**](#filter_if)
    -   [**Filter\_at**](#filter_at)



--

**The data**  
As per previous blog posts, many of these functions truly shine when you
have a lot of columns, but to make it easy on people to copy paste code
and experiment, I'm using a built-in dataset. This dataset is built into
ggplot2, so if you load tidyverse you will get it. Otherwise, just add
once `msleep <- ggplot2::msleep` argument to have the dataset available.

    library(dplyr)
    library(stringr)
    msleep <- ggplot2::msleep

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

**Basic row filters**
---------------------

In many cases you don't want to include all rows in your analysis but
only a selection of rows. The function to use only specific rows is
called `filter()` in dplyr. The general syntax of filter is:
`filter(dataset, condition)`. In case you filter inside a pipeline, you
will only see the condition argument as the dataset is piped into the
function.

### **Filtering rows based on a numeric variable**

You can filter numeric variables based on their values. The most used
operators for this are `>`, `>=`, `<`, `<=`, `==` and `!=`.

    msleep %>% 
      select(name, sleep_total) %>% 
      filter(sleep_total > 18)

    ## # A tibble: 4 x 2
    ##   name                 sleep_total
    ##   <chr>                      <dbl>
    ## 1 Big brown bat               19.7
    ## 2 Thick-tailed opposum        19.4
    ## 3 Little brown bat            19.9
    ## 4 Giant armadillo             18.1

If you want to select a range of values you can use two logical
requirements. For instance to select all animals with a total sleep time
between 15 and 18 hours, I could use:
`filter(sleep_total >= 16, sleep_total <= 18)`, but there is a slightly
shorter way by using the `between()` function.

    msleep %>% 
      select(name, sleep_total) %>% 
      filter(between(sleep_total, 16, 18))

    ## # A tibble: 4 x 2
    ##   name                   sleep_total
    ##   <chr>                        <dbl>
    ## 1 Owl monkey                    17.0
    ## 2 Long-nosed armadillo          17.4
    ## 3 North American Opossum        18.0
    ## 4 Arctic ground squirrel        16.6

Another function that can come in handy is `near()`, which will select
all code that is nearly a given value. You have to specify a tolerance
`tol` to indicate how far the values can be. You can add a specific
number: `filter(near(sleep_total, 17, tol = 0.5))` for instance will
return any rows where `sleep_total` is between 16.5 and 17.5, or you can
add a formula.  
The sample code will return all rows that are within one standard
deviation of 17.

    msleep %>% 
      select(name, sleep_total) %>% 
      filter(near(sleep_total, 17, tol = sd(sleep_total)))

    ## # A tibble: 26 x 2
    ##    name                       sleep_total
    ##    <chr>                            <dbl>
    ##  1 Owl monkey                        17.0
    ##  2 Mountain beaver                   14.4
    ##  3 Greater short-tailed shrew        14.9
    ##  4 Three-toed sloth                  14.4
    ##  5 Long-nosed armadillo              17.4
    ##  6 North American Opossum            18.0
    ##  7 Big brown bat                     19.7
    ##  8 Western american chipmunk         14.9
    ##  9 Thick-tailed opposum              19.4
    ## 10 Mongolian gerbil                  14.2
    ## # ... with 16 more rows

<br>

### **Filtering based on a exact character variable matches**

If you want to select a specific group of animals for instance you can
use the `==` comparison operator:

    msleep %>% 
      select(order, name, sleep_total) %>% 
      filter(order == "Didelphimorphia")

    ## # A tibble: 2 x 3
    ##   order           name                   sleep_total
    ##   <chr>           <chr>                        <dbl>
    ## 1 Didelphimorphia North American Opossum        18.0
    ## 2 Didelphimorphia Thick-tailed opposum          19.4

Simarly you can use the other operators:  
`filter(order != "Rodentia")` will select everything except the Rodentia
rows.  
`filter(name > "v")` will just select the rows with a name in the
alphabet after the letter v.

If you want to select more than one animal you can use the `%in%`
operator. The following code will just select the rows with animals
belonging to the order of Didelphimorphia and Diprotodontia.

    msleep %>% 
      select(order, name, sleep_total) %>% 
      filter(order %in% c("Didelphimorphia", "Diprotodontia"))

    ## # A tibble: 4 x 3
    ##   order           name                   sleep_total
    ##   <chr>           <chr>                        <dbl>
    ## 1 Didelphimorphia North American Opossum        18.0
    ## 2 Didelphimorphia Thick-tailed opposum          19.4
    ## 3 Diprotodontia   Phalanger                     13.7
    ## 4 Diprotodontia   Potoroo                       11.1

You can use the `%in%` operator to deselect certain groups as well, in
this case you have to negate by adding an exclamation mark at the
beginning of your `filter`. Making a `!%in%` might seem logic but it
won't work.

    remove <- c("Rodentia", "Carnivora", "Primates")
    msleep %>% 
      select(order, name, sleep_total) %>% 
      filter(!order %in% remove)

    ## # A tibble: 37 x 3
    ##    order           name                       sleep_total
    ##    <chr>           <chr>                            <dbl>
    ##  1 Soricomorpha    Greater short-tailed shrew       14.9 
    ##  2 Artiodactyla    Cow                               4.00
    ##  3 Pilosa          Three-toed sloth                 14.4 
    ##  4 Artiodactyla    Roe deer                          3.00
    ##  5 Artiodactyla    Goat                              5.30
    ##  6 Soricomorpha    Star-nosed mole                  10.3 
    ##  7 Soricomorpha    Lesser short-tailed shrew         9.10
    ##  8 Cingulata       Long-nosed armadillo             17.4 
    ##  9 Hyracoidea      Tree hyrax                        5.30
    ## 10 Didelphimorphia North American Opossum           18.0 
    ## # ... with 27 more rows

<br>

### **Filtering rows based on regex**

The above options will only work if you can use the full variable
content. In some cases though it will be needed to filter based on
partial matches. In this case, we need a function that will evaluate
regular expressions on strings and return boolean values. Whenever the
statement is `TRUE` the row will be filtered.  
There are two main options for this: base R's `grepl()` function, or
`str_detect()` from the `stringr` package.

Whenever you are looking for partial matches, it is important to
remember that R is case sensitive. By just using
`filter(str_detect(name, pattern="mouse"))` we would leave out any row
called Mouse. In this case it does not make a difference, but it's a
good habit to create.

I used `str_detect()` below as it is easier to understand. For those
interested, the alternative would be:
`filter(grepl(pattern="mouse", tolower(name)))`.

    msleep %>% 
      select(name, sleep_total) %>% 
      filter(str_detect(tolower(name), pattern = "mouse"))

    ## # A tibble: 5 x 2
    ##   name                       sleep_total
    ##   <chr>                            <dbl>
    ## 1 Vesper mouse                      7.00
    ## 2 House mouse                      12.5 
    ## 3 Northern grasshopper mouse       14.5 
    ## 4 Deer mouse                       11.5 
    ## 5 African striped mouse             8.70

<br>

### **Filtering based on multiple conditions**

The above examples return rows based on a single condition, but the
filter option allows also AND and OR style filters:

-   `filter(condition1, condition2)` will return rows where both
    conditions are met.  
-   `filter(condition1, !condition2)` will return all rows where
    condition one is true but condition 2 is not.  
-   `filter(condition1 | condition2)` will return rows where condition 1
    and/or condition 2 is met.  
-   `filter(xor(condition1, condition2)` will return all rows where only
    one of the conditions is met, and not when both conditions are met.

Multiple AND, OR and NOT conditions can be combined. The sample code will
return all rows with a bodywt above 100 and either have a sleep\_total
above 15 or are not part of the Carnivora order.

    msleep %>% 
      select(name, order, sleep_total:bodywt) %>% 
      filter(bodywt > 100, (sleep_total > 15 | order != "Carnivora"))

    ## # A tibble: 10 x 8
    ##    name      order  sleep_total sleep_rem sleep_cycle awake brainwt bodywt
    ##    <chr>     <chr>        <dbl>     <dbl>       <dbl> <dbl>   <dbl>  <dbl>
    ##  1 Cow       Artio~        4.00     0.700       0.667 20.0    0.423    600
    ##  2 Asian el~ Probo~        3.90    NA          NA     20.1    4.60    2547
    ##  3 Horse     Peris~        2.90     0.600       1.00  21.1    0.655    521
    ##  4 Donkey    Peris~        3.10     0.400      NA     20.9    0.419    187
    ##  5 Giraffe   Artio~        1.90     0.400      NA     22.1   NA        900
    ##  6 Pilot wh~ Cetac~        2.70     0.100      NA     21.4   NA        800
    ##  7 African ~ Probo~        3.30    NA          NA     20.7    5.71    6654
    ##  8 Tiger     Carni~       15.8     NA          NA      8.20  NA        163
    ##  9 Brazilia~ Peris~        4.40     1.00        0.900 19.6    0.169    208
    ## 10 Bottle-n~ Cetac~        5.20    NA          NA     18.8   NA        173

Example with `xor()`

    msleep %>%
      select(name, bodywt:brainwt) %>% 
      filter(xor(bodywt > 100, brainwt > 1))

    ## # A tibble: 5 x 3
    ##   name            bodywt brainwt
    ##   <chr>            <dbl>   <dbl>
    ## 1 Cow              600     0.423
    ## 2 Horse            521     0.655
    ## 3 Donkey           187     0.419
    ## 4 Human             62.0   1.32 
    ## 5 Brazilian tapir  208     0.169

Example with `!`:  
The sample code will select all rows where `brainwt` is larger than 1,
but `bodywt` does not exceed 100.

    msleep %>% 
      select(name, sleep_total, brainwt, bodywt) %>% 
      filter(brainwt > 1, !bodywt > 100)

    ## # A tibble: 1 x 4
    ##   name  sleep_total brainwt bodywt
    ##   <chr>       <dbl>   <dbl>  <dbl>
    ## 1 Human        8.00    1.32   62.0

<br>

### **Filtering out empty rows**

To filter out empty rows, you negate the `is.na()` function inside a
filter:  
The sample code will remove any rows where `conservation` is `NA`.

    msleep %>% 
      select(name, conservation:sleep_cycle) %>% 
      filter(!is.na(conservation))

    ## # A tibble: 54 x 5
    ##    name                     conservation sleep_total sleep_rem sleep_cycle
    ##    <chr>                    <chr>              <dbl>     <dbl>       <dbl>
    ##  1 Cheetah                  lc                 12.1     NA          NA    
    ##  2 Mountain beaver          nt                 14.4      2.40       NA    
    ##  3 Greater short-tailed sh~ lc                 14.9      2.30        0.133
    ##  4 Cow                      domesticated        4.00     0.700       0.667
    ##  5 Northern fur seal        vu                  8.70     1.40        0.383
    ##  6 Dog                      domesticated       10.1      2.90        0.333
    ##  7 Roe deer                 lc                  3.00    NA          NA    
    ##  8 Goat                     lc                  5.30     0.600      NA    
    ##  9 Guinea pig               domesticated        9.40     0.800       0.217
    ## 10 Grivet                   lc                 10.0      0.700      NA    
    ## # ... with 44 more rows

<br><br>
<hr>
<br>

**Filtering across multiple columns**
-------------------------------------

The `dplyr` package has a few powerful variants to filter across
multiple columns in one go:

-   `Filter_all` to filter across all columns  
-   `Filter_if` and `filter_at` to filter across a few specified columns

In these cases, there is a general syntax: first you specify which
columns, then you mention the condition for the filter. In many cases
you will need a `.` operator within the condition which refers to the
values we are looking at.

### **Filter\_all**

Admittedly, `msleep` is not the best database to showcase this power,
but imagine you have a database with a few columns and you want to
select all rows that have a certain word in either column. Take a
financial dataframe for instance and you want to select all rows with
'food', whether food is mentioned in the main category column, the
subcategory column, the comments column or the place you've spent it.  
You could make a long filter statement with 4 different conditions
wrapped inside OR statements. Or you just filter across all columns for
the string "food".

In the sample code below I'm searching for the string "Ca" across all
columns. I want to keep rows where the string "Ca" is present in ANY of
the variables, so I will wrqp the condition in `any_vars()`.  
The below code basically asks to retain any rows where any of the
variables has the pattern "Ca" inside.

    msleep %>% 
      select(name:order, sleep_total, -vore) %>% 
      filter_all(any_vars(str_detect(., pattern = "Ca")))

    ## # A tibble: 16 x 4
    ##    name              genus        order        sleep_total
    ##    <chr>             <chr>        <chr>              <dbl>
    ##  1 Cheetah           Acinonyx     Carnivora          12.1 
    ##  2 Northern fur seal Callorhinus  Carnivora           8.70
    ##  3 Vesper mouse      Calomys      Rodentia            7.00
    ##  4 Dog               Canis        Carnivora          10.1 
    ##  5 Roe deer          Capreolus    Artiodactyla        3.00
    ##  6 Goat              Capri        Artiodactyla        5.30
    ##  7 Guinea pig        Cavis        Rodentia            9.40
    ##  8 Domestic cat      Felis        Carnivora          12.5 
    ##  9 Gray seal         Haliochoerus Carnivora           6.20
    ## 10 Tiger             Panthera     Carnivora          15.8 
    ## 11 Jaguar            Panthera     Carnivora          10.4 
    ## 12 Lion              Panthera     Carnivora          13.5 
    ## 13 Caspian seal      Phoca        Carnivora           3.50
    ## 14 Genet             Genetta      Carnivora           6.30
    ## 15 Arctic fox        Vulpes       Carnivora          12.5 
    ## 16 Red fox           Vulpes       Carnivora           9.80

The same can be done for numerical values: This code will retain any
rows that has any value below 0.1:

    msleep %>%  
      select(name, sleep_total:bodywt) %>% 
      filter_all(any_vars(. < 0.1))

    ## # A tibble: 47 x 7
    ##    name           sleep_total sleep_rem sleep_cycle awake  brainwt  bodywt
    ##    <chr>                <dbl>     <dbl>       <dbl> <dbl>    <dbl>   <dbl>
    ##  1 Owl monkey           17.0      1.80       NA      7.00  1.55e-2 4.80e-1
    ##  2 Greater short~       14.9      2.30        0.133  9.10  2.90e-4 1.90e-2
    ##  3 Vesper mouse          7.00    NA          NA     17.0  NA       4.50e-2
    ##  4 Dog                  10.1      2.90        0.333 13.9   7.00e-2 1.40e+1
    ##  5 Roe deer              3.00    NA          NA     21.0   9.82e-2 1.48e+1
    ##  6 Guinea pig            9.40     0.800       0.217 14.6   5.50e-3 7.28e-1
    ##  7 Chinchilla           12.5      1.50        0.117 11.5   6.40e-3 4.20e-1
    ##  8 Star-nosed mo~       10.3      2.20       NA     13.7   1.00e-3 6.00e-2
    ##  9 African giant~        8.30     2.00       NA     15.7   6.60e-3 1.00e+0
    ## 10 Lesser short-~        9.10     1.40        0.150 14.9   1.40e-4 5.00e-3
    ## # ... with 37 more rows

The `any_vars()` statement is equivalent to OR, so of course there is an
equivalent for AND statements as well:`all_vars()`. The below code will
retain any rows where all values are above 1.

    msleep %>%  
      select(name, sleep_total:bodywt, -awake) %>% 
      filter_all(all_vars(. > 1))

    ## # A tibble: 1 x 6
    ##   name  sleep_total sleep_rem sleep_cycle brainwt bodywt
    ##   <chr>       <dbl>     <dbl>       <dbl>   <dbl>  <dbl>
    ## 1 Human        8.00      1.90        1.50    1.32   62.0

<br>

### **Filter\_if**

The `filter_all()` function can sometimes go a bit wild. The `msleep`
dataset has a set of sleep and weight measurements where some data is
missing - there is nothing I can do to add data there. But the first few
set of columns just contain info on animals. The vore of Vesper Mouse is
missing, but that is info I can still dig up and add to the dataframe if
I wanted.  
So imagine I want to find out all data rows where we NA in the first few
columns. `filter_all(any_vars(is.na(.)))` will be quite useless because
it would return 27 rows, many of which are missing data in the
measurement section.

In this case: `filter_if()` comes in handy. The describing columns are
all character columns, while the measurement data is numeric. So using
`filter_if()` I can specify that I want to just filter on character
variables. In this case I only get 7 rows.

    msleep %>% 
      select(name:order, sleep_total:sleep_rem) %>% 
      filter_if(is.character, any_vars(is.na(.)))

    ## # A tibble: 7 x 6
    ##   name            genus       vore  order          sleep_total sleep_rem
    ##   <chr>           <chr>       <chr> <chr>                <dbl>     <dbl>
    ## 1 Vesper mouse    Calomys     <NA>  Rodentia              7.00    NA    
    ## 2 Desert hedgehog Paraechinus <NA>  Erinaceomorpha       10.3      2.70 
    ## 3 Deer mouse      Peromyscus  <NA>  Rodentia             11.5     NA    
    ## 4 Phalanger       Phalanger   <NA>  Diprotodontia        13.7      1.80 
    ## 5 Rock hyrax      Procavia    <NA>  Hyracoidea            5.40     0.500
    ## 6 Mole rat        Spalax      <NA>  Rodentia             10.6      2.40 
    ## 7 Musk shrew      Suncus      <NA>  Soricomorpha         12.8      2.00

Similarly, you can add `is.numeric`, `is.integer`, `is.double`,
`is.logical`, `is.factor`. If you have data columns, you can load the
lubridate package, and use `is.POSIXt` or `is.Date`.

<br>

### **Filter\_at**

One of the more powerful functions is `filter_at()`: it does not filter
all columns, nor does it need you to specify the type of column, you can
just select columns to which the change should happen via the `vars()`
argument. This argument allows anything that can be done within a select
statement: so you can refer to them by name, but also by logical
numerical functions, regex, etc (See my first blog post for select
options).

The second argument is the condition for selection. Similar to the
examples above, you can use `all_vars()` if all columns need to return
TRUE (AND equivalent), or `any_vars()` in case just one variable needs
to return TRUE (OR equivalent).

Example: refer to columns by their name:

    msleep %>% 
      select(name, sleep_total:sleep_rem, brainwt:bodywt) %>% 
      filter_at(vars(sleep_total, sleep_rem), all_vars(.>5))

    ## # A tibble: 2 x 5
    ##   name                 sleep_total sleep_rem brainwt bodywt
    ##   <chr>                      <dbl>     <dbl>   <dbl>  <dbl>
    ## 1 Thick-tailed opposum        19.4      6.60 NA       0.370
    ## 2 Giant armadillo             18.1      6.10  0.0810 60.0

Example: using another select option:

    msleep %>% 
      select(name, sleep_total:sleep_rem, brainwt:bodywt) %>% 
      filter_at(vars(contains("sleep")), all_vars(.>5))

    ## # A tibble: 2 x 5
    ##   name                 sleep_total sleep_rem brainwt bodywt
    ##   <chr>                      <dbl>     <dbl>   <dbl>  <dbl>
    ## 1 Thick-tailed opposum        19.4      6.60 NA       0.370
    ## 2 Giant armadillo             18.1      6.10  0.0810 60.0
