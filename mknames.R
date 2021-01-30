library(jsonlite)
library(doParallel)

# generate list of unique tracks by uri.
# script assumed running in same directory as all data

# get list of all 1000 files
f <- list.files(pattern="\\.json")

# hardcode sane number of parallel jobs, ran on local
# machine, 20mins total
#nc <- detectCores()
nc <- 8

# split file list into nc batches
i <- splitIndices(length(f), nc)
fi <- sapply(i, function(i) f[i])

# start up workers
cl <- makeCluster(nc)
registerDoParallel(cl)
# send split objects file indices from the splits to each worker
l <- foreach(f=fi, .inorder=FALSE, .packages=c("jsonlite")) %dopar% {
	# gather all tracks from each json
	trk <- sapply(f, function(f){
		d <- fromJSON(f)
		# gather tracks from each playlist
		lapply(d$playlists$tracks, function(x) x$track_uri)
	})
	# get unique tracks for this batch
	unique(unlist(trk))
}
# reap workers
stopCluster(cl)
# write unique track uri's across all batches one per line
trk <- unique(unlist(l))
write.table(trk, file="names.txt", quote=FALSE, row.names=FALSE, col.names=FALSE)
