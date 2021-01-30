library(jsonlite)
library(doParallel)

f <- list.files(pattern="\\.json")

#nc <- detectCores()
nc <- 8

i <- splitIndices(length(f), nc)
fi <- sapply(i, function(i) f[i])

cl <- makeCluster(nc)
registerDoParallel(cl)
l <- foreach(f=fi, .inorder=FALSE, .packages=c("jsonlite")) %dopar% {
	trk <- sapply(f, function(f){
		d <- fromJSON(f)
		lapply(d$playlists$tracks, function(x) x$track_uri)
	})
	unique(unlist(trk))
}
stopCluster(cl)
trk <- unique(unlist(l))
write.table(trk, file="names.txt", quote=FALSE, row.names=FALSE, col.names=FALSE)
