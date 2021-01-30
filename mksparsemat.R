library(jsonlite)
library(doParallel)
library(reticulate)

# so why generate python objects from R?  because R does
# python better than python.  python sucks.  fight me.
# numpy favors low memory over performance, because of which
# an equivalent script with numpy/scipy takes over 25min for
# a single file, vs. 5min for sliced file in R, or ~1min
# unsliced.  taking overhead for parallelization into account,
# we'd have to launch over 60 workers to get anywhere near what
# we get with R.
#
# script assumed running in same directory as all data

# get list of all 1000 files
f <- list.files(pattern="\\.json")
# hardcode sane number of parallel jobs for our server
nc <- 40
# split file list into nc batches
i <- splitIndices(length(f), nc)
fi <- sapply(i, function(i) f[i])

# read in track uri file, one track per line
trk <- unlist(read.delim("names.txt", header=FALSE))
# we assume it's a straight unnamed vector
names(trk) <- NULL

# critical: to reduce memory usage by job,
# we don't load the entire json file at each iteration; this
# slows the individual proc down, but allows us to
# parallelize much more.
# unsliced version, circa 2min but >32gb
# 100 playlists at a time: circa 20min but ~12gb
slice <- splitIndices(1000, 10)

# start up workers
cl <- makeCluster(nc)
registerDoParallel(cl)
# send split objects file indices from the splits to each worker;
# import needed packages, reticulate needs to be loaded here by
# the workers, can't just pass the object
v <- foreach(f=fi, n=seq_along(i), .inorder=FALSE, .packages=c("jsonlite", "reticulate")) %dopar% {
	# import python scipy.sparse module
	ss <- import("scipy")$sparse
	# declare matrix variable
	v <- NULL
	for(i in f){
		# load json file
		j <- fromJSON(i)
		# read it slice by slice
		for(s in slice){
			# extract tracks from each playlist,
			# and convert to row of the giant boolean
			# matrix: 1s for track in playlist, 0
			# otherwise
			d <- sapply(j$playlists$tracks[s], function(x) as.numeric(trk %in% x$track_uri))
			# we force garbage collection in case
			# it doesn't trigger between steps
			gc()
			# transpose: tracks are variables (cols),
			# playlists are samples (rows)
			d <- t(d)
			gc()
			# convert to compressed sparse row matrix,
			# generate scipy object
			d <- ss$csr_matrix(d)
			gc()
			# add rows to matrix
			if(is.null(v)){
				v <- d
			}else{
				v <- rbind(v, d)
			}
		}
	}
	# return matrix for json batch
	v
}
# reap workers
stopCluster(cl)

# concatenate rows of all submatrices
mat <- do.call(rbind, v)
# write npz-format sparse matrix
ss <- import("scipy")$sparse
ss$save_npz("mat.npz", mat)
