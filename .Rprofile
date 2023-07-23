# This is designed to simply remove all existing data variables from the enviroment (i.e. "clear the cache")
# all.names determines whether to also clear hidden variables (T by default but this can spare some variables)
rm_all_data = function(all.names=T) rm(list=setdiff(ls(all.names = all.names), lsf.str(all.names = all.names)))

commandArgs=function(trailingOnly=T) base::commandArgs(trailingOnly=trailingOnly)

object.size.pretty = function(obj) format(object.size(obj), units='auto')
print.object_size = function(x) print(format(x, units='auto')) # automatically pretty-print (since numerical properties not needed for printing)

# ks.test for 2 whole data frames!
ks_df_test = function(X_df, Y_df) {
  library(purrr)
  map2(X_df, Y_df, ~ks.test(.x, .y)) %>% map('p.value')
}

# less broken abbreviate (removes space characters & uses minlength=6 by default)
abbreviate = function(x, minlength=6, ...) base::abbreviate(gsub('[_. ]', '', x), minlength=minlength, ...)
len=length # python style!

# fixes base image() function to display the matrix without rotation
image.real = function(mat, main=NULL, sub=NULL) graphics::image(t(mat)[,nrow(mat):1], main=main, sub=sub)
image = function(x, scale=F, ...) { # better version of image for labeled axes
  if (scale) x <- scale(x) # scale so that image is more readable
  x <- t(x)[,nrow(x):1] # fix base image rotation
  graphics::image(x, axes = FALSE, ...)
  if (!is.null(rownames(x))) axis(1, at = seq(0, 1, length = nrow(x)), labels = abbreviate(rownames(x)), las=2)
  if (!is.null(colnames(x))) axis(2, at = seq(0, 1, length = ncol(x)), labels = abbreviate(colnames(x)), las=2)
  box() # here we add tick labels based on matrix row & col names (abbreviated & perpendicular to the axes)
}

# verified to work 5/30/22
# a summary that always casts character columns to factors!
summary.data.frame = function(df) {
  for (col in colnames(df))
    if (is.character(df[[col]]))
      df[[col]] = as.factor(df[[col]])
  return(base::summary.data.frame(df))
}

# switch is like an ifelse which operates non-element wise
dim = function(x) switch(is.null(base::dim(x))+1, base::dim(x), length(x))
norm = function(x, type = c("F", "I", "O", "M", "2")) base::norm(as.matrix(x), type) # default is now frobenius & conversion of vector to matrix is implicit
cat = function(...) base::cat(..., '\n') # cat() now produces newlines!
barplot = function(...) { # better option: use dotchart!!
	warning('Consider using dotchart() instead of barplot...')
	graphics::barplot(..., las=2)
}
# sets default barplot configuration to have horizontal bar names (to accomodate longer names)

# requires quosure response!! (e.g. parallel_coordinate_response()
parallel_coordinate_response = function(plot_data, response, title=NULL) {
  library(tidyverse)
  stopifnot('quosure' %in% class(response))
  plot_data %>% arrange(!!response) %>% select_if(~sd(.x)>0) %>% mutate(id_=1:n()) %>%
    pivot_longer(c(-!!response,-id_)) %>%
    ggplot(aes(name, value, color=!!response, group = id_)) +
    geom_point() + geom_line() + theme(axis.text.x=element_text(angle=45)) + ggtitle(title)
}

# Everything is verified except whether it is ok to ignore bias: 8/2/22
fit_linear_transform = function(X_df, Y_df) {
  # verified to work 8/2/22 (checks that data frames are all numeric)
  stopifnot(all(Vectorize(is.numeric)(X_df)))
  stopifnot(all(Vectorize(is.numeric)(Y_df)))

  rotation_matrix = NULL
  for (j in 1:ncol(Y_df)) {
    model = lm(Y_df[,j]~.-1,data=X_df) # TODO: verify that it is ok to ignore bias here?
    rotation_matrix = cbind(rotation_matrix, coef(model))
  }
  colnames(rotation_matrix) = colnames(Y_df)

  # print R^2 of entire rotation matrix
  R2 = 1-sum(apply((as.matrix(X_df)%*%rotation_matrix-Y_df)**2, -1, mean)/apply(Y_df, -1, var))
  cat('R2 of linear transform fit: ', R2)

  return(rotation_matrix)
}

# NOTE: set avg=F to look at more detailed error analysis
# NOTE: uses linear models for R^2
get_explained_var = function(X_df, Y_df, avg=T, show_plot=T) {
  library(tidyr, purrr)
  # as_vector(Y_df[,.x]) is really important because R doesn't allow prediction of more than 1 variable
  # (so it only accepts vectors as Y's in the formulae)
  x = 1:ncol(Y_df) %>% 
    purrr::map(~summary(lm(as_vector(Y_df[,.x])~., data=as_tibble(X_df)))) %>%
    purrr::map_dbl('r.squared')
  names(x)=colnames(Y_df)
  if (show_plot) dotchart(x, main='R^2 of Y_df~X_df (using lm())')
  if (avg) x=mean(x, na.rm=T) # why does R^2 get NaNs??
  return(x)
}


# Verified to work 12/29/21 (tested against hundreds of other random permutations)
# gets cumulative explained variance by incrementally increasing number of columns used
get_cummulative_variance = function(X_df, Y_df) {
  library(tidyverse)
  remaining_options = 1:ncol(X_df)
  order = NULL
  for (i in 1:ncol(X_df)) {
    new_explained_var = remaining_options %>% purrr::map(~X_df[,c(order,.x)]) %>%
      purrr::map_dbl(~get_explained_var(.x, Y_df, show_plot=F))
    next_best_i = which.max(new_explained_var) # index into remaining_options
    order = c(order, remaining_options[[next_best_i]])
    remaining_options = remaining_options[-next_best_i]
  }
  
  X_df = X_df[,order]
  1:ncol(X_df) %>% purrr::map(~X_df[,1:.x]) %>% purrr::map_dbl(~get_explained_var(.x, Y_df, show_plot=F))
}
