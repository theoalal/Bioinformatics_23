library("adegenet")
tick_pop <- read.genetix("C:/Users/Yaw/Desktop/RADseq_2ticks/186_trimmed_test/scap_persul_only/persul_data.gtx")
summary(tick_pop)
tick_pop
class(tick_pop)
names(tick_pop)
Persul_tick_clust <- find.clusters(tick_pop, max.n.clust = 20)
100
3
names(Persul_tick_clust)
table(pop(tick_pop), Persul_tick_clust$grp)
table.value(table(pop(tick_pop), Persul_tick_clust$grp), col.labels = paste("inf", 1:3), row.labels = paste("ori", 1:3))
tick_dapc1 <- dapc(tick_pop, Persul_tick_clust$grp)
11
3
scatter(tick_dapc1)
scatter(tick_dapc1, posi.da = "bottomright", bg = "white", pch = 17:22)
myCol <- c("green", "brown", "orange", "purple", "darkgreen")
scatter(tick_dapc1, posi.da = "bottomright", scree.da=TRUE, bg="white", pch=17:22, posi.pca = "bottomleft", cstar=0, col=myCol)
scatter(tick_dapc1, posi.da = "bottomright", scree.da=TRUE, bg="white", pch=17:22, posi.pca = "bottomleft", cstar=0, col=myCol, cell=0, cex=2, clab=0, legend = TRUE, text.leg=paste("Clusters", 1:3))
title(" DAPC plot for I.persulcatus ")

names(tick_dapc1)
class(tick_dapc1$posterior)
dim(tick_dapc1$posterior)
round(head(tick_dapc1$posterior), 3)
summary(tick_dapc1)
assignplot(tick_dapc1, subset = 1:87)
title("Membership Probabilities Assignment")
compoplot(tick_dapc1, posi="bottomleft", text.leg=paste("Cluster", 1:3), lab="", ncol=1, xlab="individuals", col=funky(6))
title("Group membership assignment")
dapc2 <- dapc(tick_pop, n.da=100, n.pca=11)
temp <- a.score(dapc2)
names(temp)
temp$tab[1:2, 1:2]
temp$mean
temp$pop.score
temp <- optim.a.score(dapc2)
