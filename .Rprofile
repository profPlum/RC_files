options(readr.read_lazy = TRUE) # this should be optimal in R because it only fails on windows

# IMPORTANT: use continuous_IC(dataframe, thumb='estim') to get KDE-CV tunned bandwidths!
# NOTE: Continuous means we use PDF instead of Probability!
# This isn't strictly the definition of IC & it has slightly less beautiful properties
# (e.g. the minimum isn't 0, and less intuitive definition)
continuous_IC = function(df, normalize=F, ...) {
  library(Compositional)
  df = as.matrix(df)
  stopifnot(Vectorize(is.numeric)(df))
  cat("IMPORTANT: try `continuous_IC(dataframe, thumb='estim')` to get KDE-CV tunned bandwidths!")

  kde.pdf = mkde(df, ...)
  IC = -log(kde.pdf)
  
  if (normalize) {
    IC = IC-min(IC)
    IC = IC/sum(IC)
  }
  return(IC)
}

# get cross validation KDE loglikelihood of the entire dataset
cv_kde_LL = function(df) {
    library(Compositional)
    df = as.matrix(df)
    stopifnot(is.numeric(df))
    cat('This get cross validation KDE loglikelihood of the entire dataset.')
    mkde.tune(df)$maximum
}

fit_H2O_aml = function(df, y_col, max_runtime_secs=3*60, val_split=0.0,
                   train_df=head(df, n=nrow(df)*(1-val_split)),
                   val_df=tail(df, n=nrow(df)*val_split), explain=T, ...) {
  library(h2o)
  h2o.init()
  
  #if (explain) report_IC_in_splits(train_df, val_df)
  
  train_df = as.h2o(train_df); val_df = as.h2o(val_df)
  if (!nrow(val_df)) val_df = NULL
  aml = h2o.automl(y=y_col, training_frame = train_df,
                   validation_frame = val_df,
                   max_runtime_secs=max_runtime_secs, ...)
  
  if (!is.null(val_df) && explain) print(h2o.explain(aml, val_df))

  leader = h2o.get_best_model(aml)
  cat(rep('=', 50), '\n')
  cat('h2o aml response: ', y_col, '\n')
  cat('h2o leader R^2 train: ', h2o.r2(leader, train=T), '\n')
  cat('h2o leader R^2 CV (dev): ', h2o.r2(leader, xval=T), '\n')
  if (!is.null(val_df))
    cat('h2o leader R^2 Val: ', h2o.r2(leader, val=T), '\n')
  cat(rep('=', 50), '\n')
  return(leader)
}

# Grep aliases to ignore case & use perl regex
# NOTE: unsure if this is a good alias but we'll try it out and see if it gets me into trouble
grepl = function(..., ignore.case = T, perl = T) base::grepl(..., ignore.case=ignore.case, perl=perl)
grep = function(..., ignore.case = T, perl = T) base::grep(..., ignore.case=ignore.case, perl=perl)

# NOTE: exact same behavior as the bash function version
# i.e. uses same (inclusive/exclusive) intervals as range() in python
regex_number_range = function(start=0, end) {
    x = paste0(start:(end-1), collapse='|')
    return(paste0("(?<![0-9eE.-])(?:", x , ")(?![0-9eE.])"))
}

# Verified to work 11/13/23
# regular read_csv/read.csv except it caches & instantly reloads duplicates
# IMPORTANT: It uses modification timestamps to esnure cache validitity, after more testing 
# (long term use) it should be able to wrap both read.csv and read_csv... make it happen!
if (!exists('read_csv_cached')) {
  read_csv_cached = function(fn, ...) {
    fn <- normalizePath(fn)
    cached_df=attr(read_csv_cached, 'cache')[[fn]]
    cur_info = file.info(fn)
    if (!is.null(cached_df) && cached_df$mtime==cur_info$mtime) {
      return(cached_df$df)
    } else {
      # load it
      if (require(readr)) {
        df = readr::read_csv(fn, ...)
      } else {
        df = utils::read.csv(fn, ...)
      }
      attr(read_csv_cached, 'cache')[[fn]] <<- list(df=df, mtime=cur_info$mtime)
    }
    return(df)
  }
  attr(read_csv_cached, 'cache')=list()
}

# NOTE: This is designed to simply remove all existing data variables from the enviroment (i.e. "clear the cache")
# all.names determines whether to also clear hidden variables (T by default but this can spare some variables)
# Verified to work: 12/26/23
rm_all_data = function(all.names=T) {
  names_to_remove = setdiff(ls(all.names = all.names, envir=globalenv()),
                            lsf.str(all.names = all.names, envir=globalenv()))
  cat('names to remove: ', names_to_remove)
  rm(list=names_to_remove, envir=globalenv(), inherits=T)
  stopifnot('list' %in% class(attr(read_csv_cached, 'cache'))) # sanity in case of renaming, etc...
  attr(read_csv_cached, 'cache') <<- list() # csv cache can contain lots of data!
  gc(reset=T, full=T) # do garbage collection
}

# h2o cluster & package are always getting out of date & out of sync, this makes it easy to upgrade!
reinstall_h2o = function() { remove.packages("h2o"); install.packages('h2o') }

plot.prcomp = function(PCA) {
    if (!any(summary(PCA)$scale)) warning('Unscaled PCA assumes that each variable is in the same units! If that is false this plot will be meaningless.')
    PC_importance = t(summary(PCA)$importance)
    stopifnot(colnames(PC_importance)[[3]]=='Cumulative Proportion')
    cummulative_R2 = PC_importance[,3]
    plot(cummulative_R2, main='Cummulative R2 vs Number of PCs', type='b')
}

# NOTE: Maybe mnemonic is better: to simply use negative margin with apply (sweep is numpy already)
# The dream apply which sets negative MARGINS to mimic numpy axis behavior!
# (sweep does this already without modifications)
np.apply = function(X, axis, FUN, ...) apply(X, MARGIN=-axis, FUN, ...)

# distinct() is a blazing fast alternative to unique on dataframes!! (i.e. real time vs 3 seconds)
# now it has been transparently added as a backend for unique() when called on dataframes
# (so you don't need to memorize a new command & your code will be more portable!)
unique.data.frame = function(df, ...) {
    #e = tryCatch(library(dplyr), error = function(e) e, finally = print("Hello"))
    if (require(dplyr) && !length(list(...))) df |> distinct() 
    else df |> base::unique.data.frame(...)
}


# NOTE: this is like a better relative error! Because it doesn't allow singularities
# Relative Percentage Difference: https://stats.stackexchange.com/questions/86708/how-to-calculate-relative-error-when-the-true-value-is-zero/86710#86710
sMAPE = function(Yt, Yp, na.rm=F) mean(abs(Yp-Yt)/((abs(Yp)+abs(Yt))/2), na.rm=na.rm) # Verified to work 8/3/23
MAPE = function(Yt, Yp, na.rm=F) mean(abs(Yp-Yt)/abs(Yt), na.rm=na.rm) # NOTE: MAPE doesn't actually give a percent, it's just 0-1
# R2_1d = function(Yt, Yp, na.rm=F) 1-mean((Yp-Yt)**2, na.rm=na.rm)/var(Yt, na.rm=na.rm) R2() is strictly better/more general

# Verified to work 11/15/23
# should handle matrices and 1d vectors!
R2 = function(Yt, Yp, avg=F, var_weighted=F, na.rm=F)  {
    stopifnot(!(avg && var_weighted)) # mutually exclusive
    variances = apply(as.matrix(Yt), -1, var, na.rm=na.rm)
    R2_values = 1-apply(as.matrix((Yp-Yt)**2), -1, mean, na.rm=na.rm)/variances
    R2_weights = NULL
    if (avg) R2_weights=1/length(variances)
    else if (var_weighted) R2_weights=variances/sum(variances, na.rm=na.rm)
    if (!is.null(R2_weights)) R2_values=sum(R2_values*R2_weights, na.rm=na.rm)
    return(R2_values)
}

# mean absolute deviation for most intuitive deviation from the mean metric
mad = function(x, na.rm=F) mean(abs(x-mean(x, na.rm=na.rm)), na.rm=na.rm)

###################### glmnet helpers ######################
# TODO: delete & use h2o once they fix intercept=F bug

glmnet_R2 = function(glmnet_cv_out, s='lambda.min') {
  ids = list(lambda.min=glmnet_cv_out$index[[1]], lambda.1se=glmnet_cv_out$index[[2]])
  R_Squared_train = glmnet_cv_out$glmnet.fit$dev.ratio[[ ids[[s]] ]]
  return(R_Squared_train)
}

# returns coefs as named vector (like we expect)
coef.cv.glmnet = function(cv, s='lambda.min', ...) {
  lm_coefs_raw = glmnet::coef.glmnet(cv, s=s, ...)
  lm_coefs = as.vector(lm_coefs_raw)
  names(lm_coefs) = gsub('`', '', rownames(lm_coefs_raw))
  return(lm_coefs) # gsub prevents unsual names from breaking things...
}

glmnet=function(formula, data) #TODO: figure out corresponding method for predict() which can reuse formula + new df flexibly
  glmnet::cv.glmnet(as.matrix(model.matrix(formula, data=data)), y=data[[ all.vars(formula)[[1]] ]], intercept=F) #,
                    #nfolds=min(10,as.integer(nrow(data)/3))
# if user requests it intercept will implicitly be included by formula

# Verified to work 11/8/23
# NOTE: you can pass lm=glm for glm type model! (glm doesn't show R^2 though...)
fit_significant_lm = function(formula, data, significance_level=0.05,
                              lm_fit=lm, ...) {
  # NOTE: this is how you get p_values! 
  # https://stackoverflow.com/questions/16153497/selecting-the-statistically-significant-variables-in-an-r-glm-model
  p.vals = function(m) {
    stopifnot('lm' %in% class(m))
    return(summary(m)$coeff[-1,4])
  }
  
  # Refine lm's x.vars until only significant predictors remain
  str_formula = as.character(formula)[-1] # index [1] is the tilde
  y.var <- str_formula[[1]] # LHS
  x.vars <- str_formula[[2]] # RHS
  print(x.vars)
  sign.lm = lm_fit(formula, data=data, ...)
  while(max(p.vals(sign.lm))>significance_level) { # while insignificant predictors remain
    irrelevant.x <- names(p.vals(sign.lm))[which.max(p.vals(sign.lm))]
    x.vars <- paste0(x.vars, '-', irrelevant.x)
    print(x.vars)
    sig.formula <- as.formula(paste(y.var, "~", x.vars))
    sign.lm = lm_fit(sig.formula, data=data, ...)
  }
  print(summary(sign.lm))
  
  return(sign.lm)
}
#####################################################################

write.csv=function(df, file, ...) utils::write.csv(df, file=if (grepl('.*\\.gz',file)) gzfile(file) else file, ...)

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
  stopifnot(prod(dim(x))>0)
  if (scale) x <- scale(x) # scale so that image is more readable
  x <- t(x)[,nrow(x):1] # fix base image rotation
  graphics::image(x, axes = FALSE, ...)
  #if (!abbrev) abbreviate=function(x, ...) x # abbreviate is MANDATORY (or clipped)
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

# requires quosure response!! (e.g. parallel_coordinate_response())
parallel_coordinate_response = function(plot_data, response, 
                                        title='Parallel Coords', alpha=0.1, scale=F) {
  library(tidyverse)
  stopifnot('quosure' %in% class(response))
  if (scale) {
    plot_data = plot_data %>% mutate_at(vars(-!!response), base::scale)
    title=paste0(title, ' (Scaled)')
  }
  plot_data %>% arrange(!!response) %>% select_if(~sd(.x)>0) %>% mutate(id_=1:n()) %>%
    pivot_longer(c(-!!response,-id_)) %>%
    ggplot(aes(name, value, color=!!response, group = id_), alpha=alpha) +
    geom_point() + geom_line() + theme(axis.text.x=element_text(angle=45)) + ggtitle(title) +
    ylab(ifelse(scale, 'value (scaled)', 'value'))
}

# Everything is verified except whether it is ok to ignore bias: 8/2/22
fit_linear_transform = function(X_df, Y_df) {
  # verified to work 8/2/22 (checks that data frames are all numeric)
  stopifnot(is.numeric(as.matrix(X_df)))
  stopifnot(is.numeric(as.matrix(Y_df)))

  rotation_matrix = NULL
  for (j in 1:ncol(Y_df)) {
    # TODO: verify that it is ok to ignore bias here?
    model = lm(as.matrix(Y_df)[,j]~.-1, data=X_df) 
 
    print(summary(model))
    rotation_matrix = cbind(rotation_matrix, coef(model))
  }
  colnames(rotation_matrix) = colnames(Y_df)

  # print R^2 of entire rotation matrix
  R2 = 1-sum(apply((as.matrix(X_df)%*%rotation_matrix-Y_df)**2, -1, mean)/apply(Y_df, -1, var))
  cat('R2 of linear transform fit: ', R2)

  return(rotation_matrix)
}

# NOTE: builtin R^2 is working apparently!! Your manual implementation had a subtle bug related to h2o arrays...
# see more here: https://stackoverflow.com/questions/74368804/why-does-h2o-r2-not-match-manually-computed-r2/76995212#76995212
get_explained_var_H2O = function(X_df, Y_df, max_models = 15, max_runtime_secs=3*60) {
  library(h2o)
  Y_df_prefix = 'Y_' # this fixes issue with duplicate column names across X_df & Y_df
  colnames(Y_df) = paste0(Y_df_prefix, colnames(Y_df))
  df = as.h2o(cbind(X_df, Y_df))
  
  aml_R2 = function(Y_col) { # coupled with outer function
    aml <- h2o.automl(x=colnames(X_df), y=Y_col, training_frame=df,
                      max_models = max_models, max_runtime_secs=max_runtime_secs, nfolds=5)
    leader = h2o.get_best_model(aml)
    return(h2o.r2(leader, xval=T))
  }
  
  library(tidyr)
  library(purrr)
  colnames(Y_df) %>% purrr::map_dbl(~aml_R2(Y_col=.x)) %>% mean(na.rm=T) # why does R^2 get NaNs??
}

# NOTE: set avg=F to look at more detailed error analysis
# NOTE: uses linear models for R^2
get_explained_var = function(X_df, Y_df, avg=T, var_weighted=F, show_plot=T) {
  library(tidyr, purrr)
  stopifnot(prod(dim(X_df))>0)
  stopifnot(prod(dim(Y_df))>0)
  if (var_weighted) stopifnot(avg)
  # as_vector(Y_df[,.x]) is really important because R doesn't allow prediction of more than 1 variable
  # (so it only accepts vectors as Y's in the formulae)
  x = 1:ncol(Y_df) %>%
    purrr::map(~summary(lm(as_vector(Y_df[,.x])~., data=as_tibble(X_df)))) %>%
    purrr::map_dbl('r.squared')
  names(x)=colnames(Y_df)
  
  R2_weight = 1/length(x)
  if (var_weighted) {
    Y_var = apply(Y_df, -1, var)
    R2_weight = Y_var/sum(Y_var)
  }
  if (show_plot) dotchart(sort(x), main='R^2 of Y_df~X_df (using lm())')
  if (avg) x=sum(x*R2_weight, na.rm=T) # why does R^2 get NaNs??
  return(x)
}


# Verified to work 8/2/23 (tested against slow version)
# IMPORTANT: Order is for orthogonalized columns, b/c it uses 
# QR decomposition for speed (i.e. no need for brute force search). 
# QR is often desirable if columns aren't interpretable. 
get_cummulative_variance_fast = function(X_df, Y_df) {
  library(purrr)
  
  # Idea is: since this is a linear model fit we might as well make predictors
  # linearly independent first. This allows faster ordering!
  Q = X_df |> as.matrix() |> qr() |> qr.Q()
  Q_cols_R2 = 1:ncol(Q) |> map_dbl(~get_explained_var(Q[,.x], Y_df, show_plot=F))
  new_order = rev(order(Q_cols_R2))
  Q = Q[,new_order] # sort Q by indep explained variance

  R2 = 1:ncol(Q) %>% purrr::map(~Q[,1:.x]) %>% purrr::map_dbl(~get_explained_var(.x, Y_df, show_plot=F))
  names(R2) = new_order
  return(R2)
}

# Verified to work 12/29/21 (tested against hundreds of other random permutations)
# gets cumulative explained variance by incrementally increasing number of columns used
# (it greedily chooses the next component which gives the highest explained_variance lift)
# IMPORTANT: also returns the optimal order of components w.r.t explained variance which is non-trivial!!
get_cummulative_variance = function(X_df, Y_df) {
  library(purrr)
  remaining_options = 1:ncol(X_df)
  order = NULL
  for (i in 1:ncol(X_df)) {
    #test_lifted_R2 = compose(~get_explained_var(.x, Y_df, show_plot=F),~X_df[,c(order,.x)])
    new_explained_var = remaining_options %>% purrr::map(~X_df[,c(order,.x)]) %>%
      purrr::map_dbl(~get_explained_var(.x, Y_df, show_plot=F))
    next_best_i = which.max(new_explained_var) # index into remaining_options
    order = c(order, remaining_options[[next_best_i]])
    remaining_options = remaining_options[-next_best_i]
  }
  
  X_df = X_df[,order]
  R2 = 1:ncol(X_df) %>% purrr::map(~X_df[,1:.x]) %>% purrr::map_dbl(~get_explained_var(.x, Y_df, show_plot=F))
  names(R2) = order
  return(R2)
}
