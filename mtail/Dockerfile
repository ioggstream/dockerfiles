FROM insecurity/golang:latest
MAINTAINER robipolli@gmail.com

RUN apt-get -y update && \
	apt-get -y install git && \
	apt-get -y clean

RUN go get github.com/google/mtail || \
	cd /go/src/github.com/google/mtail && make 

#  RUN rm /go/src -fr && apt-get -y remove git



ENTRYPOINT ["/go/bin/mtail"]

