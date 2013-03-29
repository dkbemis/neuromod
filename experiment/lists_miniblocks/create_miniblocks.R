# Generation of language localizer stimuli lists

# Time-stamp: <2012-12-19 13:21:02 pallier>

# TODO : add targets

sent <- read.table('../materials/sentences.csv', sep=',', quote='', as.is=T)
nsent <-  nrow(sent)

pseu <- read.table('../materials/pseudo_sentences.final.csv', sep=',', quote='',, as.is=T)
npseu <- nrow(pseu)

SOA <- 300 # duration of a frame in msec
nblanks <- 3 # number of empty frames between successive senten
IBI <- 8000 # interblock interval in msec

onset <- 0
nminiblocks <-8
nlists <- 32
for (i in 1:nlists)
{
    # randomly select 30 sentences & 30 pseudosent
    s <- sent[sample(1:nsent,30),]
    p <- pseu[sample(1:nsent,30),]

    df <-  data.frame()
    for (miniblock in 1:nminiblocks)
    {
        i1 <-  1 + 3 * (miniblock - 1)
        i2 <-  i1 + 1
        i3 <-  i1 + 2

        w <- c(s[i1,],
               rep('',nblanks),
               s[i2,],
               rep('',nblanks),
               s[i3,])
        df <- rbind(df, data.frame(onset=onset, cond='sentence', target='', w))
        onset <- onset + length(w)*SOA + IBI

        w <- c(p[i1,],
               rep('',nblanks),
               p[i2,],
               rep('',nblanks),
               p[i3,])
        df <- rbind(df, data.frame(onset=onset, cond='pseudo', target='', w))
        onset <-  onset + length(w)*SOA + IBI
    }
    write.csv(df,sprintf("run%02d.csv",i))
}

