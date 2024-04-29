


## Installation

### Set up R dependencies

- Ensure the [R package `{renv}`](https://rstudio.github.io/renv/articles/renv.html) is installed.
- Use `renv::restore()` to set up all R dependencies

```r
# install.packages("renv") # if renv is not installed
renv::restore()
```

### Set up Python dependencies

One of the tool in the benchmark uses Python, but these dependencies can be managed from R as well.


```r
# reticulate::install_python(version = "3.9.13") # If the installed python version is <3.9
renv::use_python() # with virtualenv
reticulate::py_install(packages = c("pandas==1.4.4",
                                    "numpy==1.22.0",
                                    "numba==0.56.0"))
```
