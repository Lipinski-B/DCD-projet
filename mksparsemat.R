library(jsonlite)
library(doParallel)
library(reticulate)

f <- list.files(pattern="\\.json")
nc <- 40
i <- splitIndices(length(f), nc)
fi <- sapply(i, function(i) f[i])

trk <- unlist(read.delim("names.txt", header=FALSE))
names(trk) <- NULL

slice <- splitIndices(1000, 10)

cl <- makeCluster(nc)
registerDoParallel(cl)
v <- foreach(f=fi, n=seq_along(i), .inorder=FALSE, .packages=c("jsonlite", "reticulate")) %dopar% {
	ss <- import("scipy")$sparse
	v <- NULL
	for(i in f){
		j <- fromJSON(i)
		for(s in slice){
			d <- sapply(j$playlists$tracks[s], function(x) as.numeric(trk %in% x$track_uri))
			gc()
			d <- t(d)
			gc()
			d <- ss$csr_matrix(d)
			gc()
			if(is.null(v)){
				v <- d
			}else{
				v <- rbind(v, d)
			}
		}
	}
	v
}
stopCluster(cl)

mat <- do.call(rbind, v)
ss <- import("scipy")$sparse
ss$save_npz("mat.npz", mat)
