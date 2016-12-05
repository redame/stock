

calcuratePeakBottom<-function(stockData,term){
	len<-nrow(stockData)
	peak<-rep(F,times=len)
	bottom<-rep(F,times=len)
	
	techLine1Vector<-rep(0,times=len)
	techLine2Vector<-rep(0,times=len)
	techLine3Vector<-rep(0,times=len)
	
	i<-0
	j<-0
	tech1Size<-0
	tech2Size<-0
	tech3Size<-0
	
	for(i in 0:(len-1)){
		h<-stockData $High[i+1]
		l<-stockData $Low[i+1]
		p<-T
		b<-T
		#cat("i=",i,"\n")
		for(j in (i-term):(i-1)){
			if( j>=0 && j<len){
				h2<-stockData $High[j+1]
				l2<-stockData $Low[j+1]
				#cat("j=",j,",h2=",h2,",l2=",l2,"\n")
				if(h2>=h){
					p<-F
				}
				if(l2<=l){
					b<-F
				}
				if(!p && !b)break
			}
		}
		#cat("p=",p,",b=",b,"\n")
		if(!p && !b){
			next
		}
		for(j in (i+1):(i+term)){
			if(j>=0 && j<len){
				h3<-stockData $High[j+1]
				l3<-stockData $Low[j+1]
				#cat("j=",j,",h3=",h3,",l3=",l3,"\n")
			}
			if(h3>=h){
				p<-F
			}
			if(l3<=l){
				b<-F
			}
			if(!p && !b)break;
		}
		#cat("p=",p,",b=",b,"\n")
		if(p || b){
			techLine1Vector[tech1Size+1]<-i+1
			tech1Size<-tech1Size+1
			if(p){
				techLine2Vector[tech2Size+1]<-1
			}
			if(b){
				techLine3Vector[tech3Size+1]<-1
			}
			tech2Size<-tech2Size+1
			tech3Size<-tech3Size+1
		}
	}
	if(tech2Size>0){
		maxCnt<-0
		while(T){
			breaked<-F
			p0<-F
			if(techLine2Vector[1]==1){
				p0<-T
			}
			v2sz<-tech2Size
			#cat("v2sz=",v2sz,"\n")
			for(i in 1:(v2sz-1)){
				p1<-F
				#cat("i=",i,"\n")
				if(techLine2Vector[i+1]==1 && techLine3Vector[i+1]==1){
					if(p0){
						p1<-F
						techLine2Vector[i+1]<-0
					}else{
						p1<-T
						techLine3Vector[i+1]<-0
					}
				}else{
					if(techLine2Vector[i+1]==1){
						p1<-T
					}
				}
				#cat("p0=",p0,",p1=",p1,"\n")
				if(p0==p1){
					i0<-techLine1Vector[i]
					i1<-techLine1Vector[i+1]
					v0<-stockData $Low[i0+1]
					v1<-stockData $Low[i1+1]
					if(p1){
						v0<-stockData $High[i0+1]
						v1<-stockData $High[i1+1]
					}
					#cat("i0=",i0,",i1=",i1,",v0=",v0,",v1=",v1,"\n")
		
					if((v0<v1)==p1){
						if(tech1Size-1>=i){
							for(k in i:(tech1Size-1)){
								techLine1Vector[k]<-techLine1Vector[k+1]
							}
						}
						tech1Size<-tech1Size-1
						
						if(tech2Size-1>=i){
							for(k in i:(tech2Size-1)){
								techLine2Vector[k]<-techLine2Vector[k+1]
							}
						}
						tech2Size<-tech2Size-1
						
						if(tech3Size-1>=i){
							for(k in i:(tech3Size-1)){
								techLine3Vector[k]<-techLine3Vector[k+1]
							}
						}
						tech3Size<-tech3Size-1
					}else{
						if(tech1Size-1>=i){			
							for(k in (i+1):(tech1Size-1)){
								techLine1Vector[k]<-techLine1Vector[k+1]
							}
						}
						tech1Size<-tech1Size-1
						
						if(tech2Size-1>=i){
							for(k in (i+1):(tech2Size-1)){
								techLine2Vector[k]<-techLine2Vector[k+1]
							}
						}
						tech2Size<-tech2Size-1
	
						if(tech3Size-1>=i){
							for(k in (i+1):(tech3Size-1)){
								techLine3Vector[k]<-techLine3Vector[k+1]
							}
						}
						tech3Size<-tech3Size-1
						
					}
					#cat("tech1Size=",tech1Size,"\n")
					breaked<-T
					break
				
				}
				p0<-p1
			}
			#cat("breaked=",breaked,",maxCnt=",maxCnt,"\n")
			if(!breaked)break
			
			maxCnt<-maxCnt+1
			if(maxCnt>1000)break
		}
	}	
	
	for(i in 0:(tech1Size-1)){
		adr<-techLine1Vector[i+1]
		if(techLine2Vector[i+1]==1){
			peak[adr]<-T
		}else if(techLine3Vector[i+1]==1){
			bottom[adr]<-T
		}
	}
	
	ret<- data.frame(Peak=peak,Bottom=bottom)

}


