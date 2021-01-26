library(jsonlite)
library(doParallel)

f <- list.files("data", pattern="\\.json", full.names=TRUE)

nc <- detectCores()
i <- splitIndices(length(f), nc)
fi <- sapply(i, function(i) f[i])

cl <- makeCluster(nc)
registerDoParallel(cl)
#for(f in fi){
l <- foreach(f=fi, .inorder=FALSE, .packages=c("jsonlite")) %dopar% {
	trk <- sapply(f, function(f){
		d <- fromJSON(f)
		lapply(d$playlists$tracks, function(x) x$track_uri)
	})
	n <- sapply(trk, length)
	utrk <- unique(unlist(trk))
	q <- quantile(probs=c(0.025, 0.25, 0.5, 0.75, 0.975), n)
	df <- data.frame(n=sum(n), min=min(n), max=max(n), q025=q[1], q25=q[2], q50=q[3], q75=q[4], q975=q[5], mean=mean(n), sd=sd(n))
	list(n=n, trk=utrk, stt=df)
}
stopCluster(cl)
trk <- unique(unlist(sapply(l, "[", "trk")))
write.table(trk, file="fullnames.txt", quote=FALSE, row.names=FALSE, col.names=FALSE)

stt <- do.call(rbind, sapply(l, "[", "stt"))
write.table(stt, file="fullstats.tsv", sep="\t", quote=FALSE, row.names=FALSE)

write.table(unlist(sapply(l, "[", "n")), file="fulln.txt", quote=FALSE, row.names=FALSE, col.names=FALSE)

#hist(unlist(sapply(l, "[", "n")), breaks=100)
#boxplot(unlist(sapply(l, "[", "n")), breaks=100)
