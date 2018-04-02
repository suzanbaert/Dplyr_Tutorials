-   [Data Wrangling Part 4: Summarizing and slicing your
    data](#data-wrangling-part-4-summarizing-and-slicing-your-data)
    -   [**Counting cases**](#counting-cases)
        -   [tally, add\_tally and
            add\_count](#tally-add_tally-and-add_count)
    -   [**Summarising data**](#summarising-data)
    -   [**Summarise\_all()**](#summarise_all)
        -   [**Summarise\_all**](#summarise_all-1)
        -   [**Summarise\_if**](#summarise_if)
        -   [**Summarise\_at**](#summarise_at)
    -   [**Arranging rows**](#arranging-rows)
    -   [**Showing only part of your
        data**](#showing-only-part-of-your-data)
        -   [The 5 lowest and highest
            values](#the-5-lowest-and-highest-values)
        -   [A random selection of rows](#a-random-selection-of-rows)
        -   [A user-defined slice of
            rows](#a-user-defined-slice-of-rows)

Data Wrangling Part 4: Summarizing and slicing your data
========================================================

This is the fourh blog post in a series of dplyr tutorials:

-   [Part 1: Basic to Advanced Ways to Select
    Columns](https://suzanbaert.netlify.com/2018/01/dplyr-tutorial-1/)
-   [Part 2: Transforming your columns into the right
    shape](https://suzan.rbind.io/2018/02/dplyr-tutorial-2/)
-   [Part 3: Filtering
    rows](https://suzan.rbind.io/2018/02/dplyr-tutorial-3/))

Content:

--

Note: as per previous blog posts, I will present everything in the form
of a pipe. In some of the below cases, this might not be necessary and
it would be just as easy to write it as a single function, but as I want
to present options that you can use in your pipes, all below examples
will be piped.

<br>

**The data**  
As per previous blog posts many of these functions truly shine when you
have a lot of columns, but to make it easy on people to copy paste code
and experiment, I'm using a built-in dataset:

    library(dplyr)
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

**Counting cases**
------------------

The easiest way to know how observations you have for a specific
variable, is to use `count()`. By adding the `sort = TRUE` argument, it
immediately returns a sorted table with descending number of
observations:

    msleep %>% 
      count(order, sort = TRUE)

    ## # A tibble: 19 x 2
    ##    order               n
    ##    <chr>           <int>
    ##  1 Rodentia           22
    ##  2 Carnivora          12
    ##  3 Primates           12
    ##  4 Artiodactyla        6
    ##  5 Soricomorpha        5
    ##  6 Cetacea             3
    ##  7 Hyracoidea          3
    ##  8 Perissodactyla      3
    ##  9 Chiroptera          2
    ## 10 Cingulata           2
    ## 11 Didelphimorphia     2
    ## 12 Diprotodontia       2
    ## 13 Erinaceomorpha      2
    ## 14 Proboscidea         2
    ## 15 Afrosoricida        1
    ## 16 Lagomorpha          1
    ## 17 Monotremata         1
    ## 18 Pilosa              1
    ## 19 Scandentia          1

You can add multiple variables to a `count()` statement; the example
below is counting by order and vore:

    msleep %>% 
      count(order, vore, sort = TRUE)

    ## # A tibble: 32 x 3
    ##    order          vore        n
    ##    <chr>          <chr>   <int>
    ##  1 Rodentia       herbi      16
    ##  2 Carnivora      carni      12
    ##  3 Primates       omni       10
    ##  4 Artiodactyla   herbi       5
    ##  5 Cetacea        carni       3
    ##  6 Perissodactyla herbi       3
    ##  7 Rodentia       <NA>        3
    ##  8 Soricomorpha   omni        3
    ##  9 Chiroptera     insecti     2
    ## 10 Hyracoidea     herbi       2
    ## # ... with 22 more rows

### tally, add\_tally and add\_count

If you're only interested in counting the total number of cases for a
dataframe, you could use `tally()`, which behaves simarly to `nrow()`.

You can't provide a variable to count with `tally()`, it only works to
count the overall number of observations. In fact, as is described in
the `dplyr` documentation, `count()` is a short-hand for `group_by()`
and `tally()`.

    msleep %>% 
      tally()

    ## # A tibble: 1 x 1
    ##       n
    ##   <int>
    ## 1    83

More interesting is the `add_tally()` function which automatically adds
a column with the overall number of observations. This is will be the
same as `mutate(n = n())`.

    msleep %>% 
      select(1:3) %>% 
      add_tally()

    ## # A tibble: 83 x 4
    ##    name                       genus       vore      n
    ##    <chr>                      <chr>       <chr> <int>
    ##  1 Cheetah                    Acinonyx    carni    83
    ##  2 Owl monkey                 Aotus       omni     83
    ##  3 Mountain beaver            Aplodontia  herbi    83
    ##  4 Greater short-tailed shrew Blarina     omni     83
    ##  5 Cow                        Bos         herbi    83
    ##  6 Three-toed sloth           Bradypus    herbi    83
    ##  7 Northern fur seal          Callorhinus carni    83
    ##  8 Vesper mouse               Calomys     <NA>     83
    ##  9 Dog                        Canis       carni    83
    ## 10 Roe deer                   Capreolus   herbi    83
    ## # ... with 73 more rows

Even more interesting is `add_count()` which takes a variable as
argument, and adds a column which the number of observations. This saves
the combination of grouping and mutating.

    msleep %>% 
      select(1:3) %>% 
      add_count(vore)

    ## # A tibble: 83 x 4
    ##    name                       genus       vore      n
    ##    <chr>                      <chr>       <chr> <int>
    ##  1 Cheetah                    Acinonyx    carni    19
    ##  2 Owl monkey                 Aotus       omni     20
    ##  3 Mountain beaver            Aplodontia  herbi    32
    ##  4 Greater short-tailed shrew Blarina     omni     20
    ##  5 Cow                        Bos         herbi    32
    ##  6 Three-toed sloth           Bradypus    herbi    32
    ##  7 Northern fur seal          Callorhinus carni    19
    ##  8 Vesper mouse               Calomys     <NA>      7
    ##  9 Dog                        Canis       carni    19
    ## 10 Roe deer                   Capreolus   herbi    32
    ## # ... with 73 more rows

<br>
<hr>
**Summarising data**
--------------------

*To note: for some functions, `dplyr` foresees both an American English
and a UK English variant. The function `summarise()` is the equivalent
of `summarize()`.*

If you just want to know the number of observations `count()` does the
job, but to produce summaries of the average, sum, standard deviation,
minimum, maximum of the data, we need `summarise()`. To use the function
you just add your new column name, and after the equal sign the
mathematics of what needs to happen: `column_name = function(variable)`.
You can add multiple summary functions behind each other.

    msleep %>% 
      summarise(n = n(), average = mean(sleep_total), maximum = max(sleep_total))

    ## # A tibble: 1 x 3
    ##       n average maximum
    ##   <int>   <dbl>   <dbl>
    ## 1    83    10.4    19.9

In most cases, we don't just want to summarise the whole data table, but
we want to get summaries by a group. To do this, you first need to
specify by which variable(s) you want to divide the data using
`group_by()`. You can add one of more variables as arguments in
`group_by()`.

    msleep %>% 
      group_by(vore) %>% 
      summarise(n = n(), average = mean(sleep_total), maximum = max(sleep_total))

    ## # A tibble: 5 x 4
    ##   vore        n average maximum
    ##   <chr>   <int>   <dbl>   <dbl>
    ## 1 carni      19   10.4     19.4
    ## 2 herbi      32    9.51    16.6
    ## 3 insecti     5   14.9     19.9
    ## 4 omni       20   10.9     18.0
    ## 5 <NA>        7   10.2     13.7

The `summarise()` call works with nearly any aggregate function

-   `n()` - gives the number of observations
-   `n_distinct(var)` - gives the numbers of unique values of `var`
-   `sum(var)`, `max(var)`, `min(var)`, ...
-   `mean(var)`, `median(var)`, `sd(var)`, `IQR(var)`, ...
-   ...

<!-- -->

    msleep %>% 
      group_by(vore) %>% 
      summarise(average_minutes = mean(sleep_total)*60)

    ## # A tibble: 5 x 2
    ##   vore    average_minutes
    ##   <chr>             <dbl>
    ## 1 carni               623
    ## 2 herbi               571
    ## 3 insecti             896
    ## 4 omni                656
    ## 5 <NA>                611

<br>
<hr>
**Summarise\_all()**
--------------------

Similarly to the filter, select and mutate functions, `summarise()`
comes with three additional functions for doing things to multiple
columns in one go: + `summarise_all()` will summarise all columns based
on your further instructions + `summarise_if()` requires a function that
returns a boolean. If that is true, the summary instructions will be
followed + `sumarise_at()` requires you to specify columns inside a
`vars()` argument for which the summary will be done.

### **Summarise\_all**

The function `summarise_all()` requires a function as argument, which it
will apply to all columns. The sample code first selects all numeric
columns, and then calculates the mean for each of them. I had to add the
`na.rm = TRUE` argument to ignore `NA` values.

    msleep %>% 
      group_by(vore) %>% 
      summarise_all(mean, na.rm=TRUE) 

    ## # A tibble: 5 x 11
    ##   vore     name genus order conservation sleep_total sleep_rem sleep_cycle
    ##   <chr>   <dbl> <dbl> <dbl>        <dbl>       <dbl>     <dbl>       <dbl>
    ## 1 carni      NA    NA    NA           NA       10.4       2.29       0.373
    ## 2 herbi      NA    NA    NA           NA        9.51      1.37       0.418
    ## 3 insecti    NA    NA    NA           NA       14.9       3.52       0.161
    ## 4 omni       NA    NA    NA           NA       10.9       1.96       0.592
    ## 5 <NA>       NA    NA    NA           NA       10.2       1.88       0.183
    ## # ... with 3 more variables: awake <dbl>, brainwt <dbl>, bodywt <dbl>

The instructions for summarizing have to be a function. When there is no
funcion availble in base R or a package to do what you want, you can
either make a function upfront, or make a function on the fly. The
sample code will add 5 to the mean of each column. The function on the
fly can be made by either using `funs(mean(., na.rm = TRUE) + 5)`, or
via a tilde: `~mean(., na.rm = TRUE) + 5`.

    msleep %>%
      group_by(vore) %>% 
      summarise_all(~mean(., na.rm = TRUE) + 5) 

    ## # A tibble: 5 x 11
    ##   vore     name genus order conservation sleep_total sleep_rem sleep_cycle
    ##   <chr>   <dbl> <dbl> <dbl>        <dbl>       <dbl>     <dbl>       <dbl>
    ## 1 carni      NA    NA    NA           NA        15.4      7.29        5.37
    ## 2 herbi      NA    NA    NA           NA        14.5      6.37        5.42
    ## 3 insecti    NA    NA    NA           NA        19.9      8.52        5.16
    ## 4 omni       NA    NA    NA           NA        15.9      6.96        5.59
    ## 5 <NA>       NA    NA    NA           NA        15.2      6.88        5.18
    ## # ... with 3 more variables: awake <dbl>, brainwt <dbl>, bodywt <dbl>

<br>

### **Summarise\_if**

The function `summarise_if()` requires two arguments:

-   First it needs information about the columns you want it to
    consider. This information needs to be a function that returns a
    boolean value. The easiest cases are functions like `is.numeric`,
    `is.integer`, `is.double`, `is.logical`, `is.factor`,
    `lubridate::is.POSIXt` or `lubridate::is.Date`.

-   Secondly, it needs information about how to summarise that data,
    which as above needs to be a function. If not a function, you can
    create a function on the fly using `funs()` or a tilde (see above).

The sample code below will return the average of all numeric columns:

    msleep %>% 
      group_by(vore) %>% 
      summarise_if(is.numeric, mean, na.rm=TRUE)

    ## # A tibble: 5 x 7
    ##   vore    sleep_total sleep_rem sleep_cycle awake brainwt  bodywt
    ##   <chr>         <dbl>     <dbl>       <dbl> <dbl>   <dbl>   <dbl>
    ## 1 carni         10.4       2.29       0.373 13.6  0.0793   90.8  
    ## 2 herbi          9.51      1.37       0.418 14.5  0.622   367    
    ## 3 insecti       14.9       3.52       0.161  9.06 0.0216   12.9  
    ## 4 omni          10.9       1.96       0.592 13.1  0.146    12.7  
    ## 5 <NA>          10.2       1.88       0.183 13.8  0.00763   0.858

One of the downsides of the aggregate summarise functions is that you do
not require a new column title. It therefore might not always be clear
what this new value is (average? median? minimum?). Luckily thanks to
similar `rename_*()` functions, it only takes one line extra to rename
them all:

    msleep %>% 
      group_by(vore) %>% 
      summarise_if(is.numeric, mean, na.rm=TRUE) %>% 
      rename_if(is.numeric, ~paste0("avg_", .))

    ## # A tibble: 5 x 7
    ##   vore    avg_sleep_total avg_sleep_rem avg_sleep_cycle avg_awake
    ##   <chr>             <dbl>         <dbl>           <dbl>     <dbl>
    ## 1 carni             10.4           2.29           0.373     13.6 
    ## 2 herbi              9.51          1.37           0.418     14.5 
    ## 3 insecti           14.9           3.52           0.161      9.06
    ## 4 omni              10.9           1.96           0.592     13.1 
    ## 5 <NA>              10.2           1.88           0.183     13.8 
    ## # ... with 2 more variables: avg_brainwt <dbl>, avg_bodywt <dbl>

<br>

### **Summarise\_at**

The function `summarise_at()` also requires two arguments:

-   First it needs information about the columns you want it to
    consider. In this case you need to wrap them inside a `vars()`
    statement. Inside `vars()` you can use anything that can be used
    inside a `select()` statement. Have a look here if you need more
    info.

-   Secondly, it needs information about how to summarise that data,
    which as above needs to be a function. If not a function, you can
    create a function on the fly using `funs()` or a tilde (see above).

The sample code below will return the average of all columns which
contain the word 'sleep'.

    msleep %>%
      group_by(vore) %>% 
      summarise_at(vars(contains("sleep")), mean, na.rm=TRUE) %>% 
      rename_at(vars(contains("sleep")), ~paste0("avg_", .))

    ## # A tibble: 5 x 4
    ##   vore    avg_sleep_total avg_sleep_rem avg_sleep_cycle
    ##   <chr>             <dbl>         <dbl>           <dbl>
    ## 1 carni             10.4           2.29           0.373
    ## 2 herbi              9.51          1.37           0.418
    ## 3 insecti           14.9           3.52           0.161
    ## 4 omni              10.9           1.96           0.592
    ## 5 <NA>              10.2           1.88           0.183

<br>
<hr>
**Arranging rows**
------------------

It's useful if your summary tables are arranged. This is when the
`arrange()` function comes in. The default format for numeric variables
is to sort ascending, but you can add the `desc()` function in your call
to change the default. For string variables, it will sort
alphabetically.

Sorting numeric variables:  
`arrange(sleep_total)` will arrange it from short sleepers to long
sleepers. In this case I wanted the opposite:

    msleep %>% 
      group_by(vore) %>% 
      summarise(avg_sleep = mean(sleep_total)) %>% 
      arrange(desc(avg_sleep))

    ## # A tibble: 5 x 2
    ##   vore    avg_sleep
    ##   <chr>       <dbl>
    ## 1 insecti     14.9 
    ## 2 omni        10.9 
    ## 3 carni       10.4 
    ## 4 <NA>        10.2 
    ## 5 herbi        9.51

If you already grouped your data, you can refer to that group within the
`arrange()` statement as well by adding a `.by_group = TRUE` statement.
This will sort by descending total sleep time, but within each group.

    msleep %>% 
      select(order, name, sleep_total) %>% 
      group_by(order) %>% 
      arrange(desc(sleep_total), .by_group = TRUE)

    ## # A tibble: 83 x 3
    ## # Groups:   order [19]
    ##    order        name         sleep_total
    ##    <chr>        <chr>              <dbl>
    ##  1 Afrosoricida Tenrec             15.6 
    ##  2 Artiodactyla Pig                 9.10
    ##  3 Artiodactyla Goat                5.30
    ##  4 Artiodactyla Cow                 4.00
    ##  5 Artiodactyla Sheep               3.80
    ##  6 Artiodactyla Roe deer            3.00
    ##  7 Artiodactyla Giraffe             1.90
    ##  8 Carnivora    Tiger              15.8 
    ##  9 Carnivora    Lion               13.5 
    ## 10 Carnivora    Domestic cat       12.5 
    ## # ... with 73 more rows

<br>
<hr>
**Showing only part of your data**
----------------------------------

In some cases, you don't just want to show all rows available. Here are
some nice shortcuts which can save time

### The 5 lowest and highest values

In some cases, you don't just want to show all rows available. You can
filter of course, but there are some shortcuts for specific needs: if
you want to select the highests 5 cases, you could combine an `arrange`
call with a `head(n=5)`. Or you can use `top_n(5)` which will retain
(unsorted) the 5 highest values.

    msleep %>% 
      group_by(order) %>% 
      summarise(average = mean(sleep_total)) %>% 
      top_n(5)

    ## # A tibble: 5 x 2
    ##   order           average
    ##   <chr>             <dbl>
    ## 1 Afrosoricida       15.6
    ## 2 Chiroptera         19.8
    ## 3 Cingulata          17.8
    ## 4 Didelphimorphia    18.7
    ## 5 Pilosa             14.4

The five lowest values can be found using `top_n(-5)`:

    msleep %>% 
      group_by(order) %>% 
      summarise(average = mean(sleep_total)) %>% 
      top_n(-5)

    ## # A tibble: 5 x 2
    ##   order          average
    ##   <chr>            <dbl>
    ## 1 Artiodactyla      4.52
    ## 2 Cetacea           4.50
    ## 3 Hyracoidea        5.67
    ## 4 Perissodactyla    3.47
    ## 5 Proboscidea       3.60

If you have more than one column, you can add the variable you want it
to use. The sample code will retain the 5 highest values of
average\_sleep.

    msleep %>% 
      group_by(order) %>% 
      summarise(average_sleep = mean(sleep_total), max_sleep = max(sleep_total)) %>% 
      top_n(5, average_sleep)

    ## # A tibble: 5 x 3
    ##   order           average_sleep max_sleep
    ##   <chr>                   <dbl>     <dbl>
    ## 1 Afrosoricida             15.6      15.6
    ## 2 Chiroptera               19.8      19.9
    ## 3 Cingulata                17.8      18.1
    ## 4 Didelphimorphia          18.7      19.4
    ## 5 Pilosa                   14.4      14.4

### A random selection of rows

Using `sample_n()` you can sample a random selection of rows.  
Alternative is `sample_frac()` allowing you to randomly select a
fraction of rows (here 10%).

    msleep %>% 
      sample_frac(.1)

    ## # A tibble: 8 x 11
    ##   name   genus  vore  order conservation sleep_total sleep_rem sleep_cycle
    ##   <chr>  <chr>  <chr> <chr> <chr>              <dbl>     <dbl>       <dbl>
    ## 1 Human  Homo   omni  Prim~ <NA>                8.00     1.90        1.50 
    ## 2 Pig    Sus    omni  Arti~ domesticated        9.10     2.40        0.500
    ## 3 Mount~ Aplod~ herbi Rode~ nt                 14.4      2.40       NA    
    ## 4 Rabbit Oryct~ herbi Lago~ domesticated        8.40     0.900       0.417
    ## 5 Cheet~ Acino~ carni Carn~ lc                 12.1     NA          NA    
    ## 6 Grivet Cerco~ omni  Prim~ lc                 10.0      0.700      NA    
    ## 7 Lion   Panth~ carni Carn~ vu                 13.5     NA          NA    
    ## 8 Owl m~ Aotus  omni  Prim~ <NA>               17.0      1.80       NA    
    ## # ... with 3 more variables: awake <dbl>, brainwt <dbl>, bodywt <dbl>

### A user-defined slice of rows

The `head()` call will standard show the first 6 rows, which can be
modified by adding a n-argument: `head(n=10)`. Similarly `tail()` will
show the final 6 rows, which again can be modified by adding a
n-argument. If you want to slice somewhere in the middle, you can use
`slice()`. The sample code will show rows 50 to 55.

    msleep %>% 
      slice(50:55)

    ## # A tibble: 6 x 11
    ##   name   genus  vore  order conservation sleep_total sleep_rem sleep_cycle
    ##   <chr>  <chr>  <chr> <chr> <chr>              <dbl>     <dbl>       <dbl>
    ## 1 Chimp~ Pan    omni  Prim~ <NA>                9.70      1.40       1.42 
    ## 2 Tiger  Panth~ carni Carn~ en                 15.8      NA         NA    
    ## 3 Jaguar Panth~ carni Carn~ nt                 10.4      NA         NA    
    ## 4 Lion   Panth~ carni Carn~ vu                 13.5      NA         NA    
    ## 5 Baboon Papio  omni  Prim~ <NA>                9.40      1.00       0.667
    ## 6 Deser~ Parae~ <NA>  Erin~ lc                 10.3       2.70      NA    
    ## # ... with 3 more variables: awake <dbl>, brainwt <dbl>, bodywt <dbl>
