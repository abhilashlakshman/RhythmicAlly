library(plotly)
library(shiny)
library(zoo)
library(RColorBrewer)
library(pracma)
library(shinydashboard)
library(zeitgebr)
#########################################################################################
# Define server logic
shinyServer(function(input, output) {
  
  output$contents <- renderTable({
    req(input$file)
    df<-read.delim(input$file$datapath,
                   header=input$header,
                   sep=input$sep)
                   # quote=input$quote)
    
    if(input$disp=="head"){
      return(head(df))
    } else {
      return(df)
    }
  })
  
#########################################################################################
  output$full.monitor <- renderPlotly({
    req(input$file)
    df<-read.delim(input$file$datapath,
                   header=input$header,
                   sep=input$sep,
                   quote=input$quote)
    modulo_tau<-input$modulotau
    s_per_day<-(60/input$bins)*modulo_tau
    
    raw<-df[,2:length(df[1,])]
    raw_mean<-as.matrix(rowMeans(raw))
    
    raw<-cbind(raw,raw_mean)
    time_series_phase<-as.matrix(df[,1])
    
    xx<-do.call(rbind, replicate(length(raw[1,]),time_series_phase[,1],
                                 simplify=FALSE))
    p_raw<-plot_ly(x=seq(1:(length(raw[1,])-1)),
                   y=seq(1:length(raw[,1])),
                   z=t(raw),
                   text=xx,
                   colors=colorRamp(c("white","darkblue","black","red")),
                   type="heatmap",
                   zauto=FALSE,
                   zmin=0,
                   zmax=input$max_z_full)%>%
      add_segments(x=c(seq(s_per_day,length(raw[,1]),
                           by=s_per_day)),
                   xend=c(seq(s_per_day,length(raw[,1]),
                              by=s_per_day)),
                   y=1,yend=length(df[1,])+2,
                   mode="lines",line=list(color="black"))%>%
      layout(title=input$`name_your_plots`,xaxis=list(title="time index"),
             yaxis=list(title="individual unit",
                        autorange="reversed",
                        tickmode="array",
                        # tickvals=seq(1,length(raw[1,]),by=5),
                        # ticktext=seq(1,length(raw[1,]),by=5),
                        showlegend=FALSE))
    p_raw
    })
  #########################################################################################
  output$all.actograms <- renderPlotly({
    
    req(input$file)
    df<-read.delim(input$file$datapath,
                   header=input$header,
                   sep=input$sep,
                   quote=input$quote)
    
    modulo_tau <- input$modulotau
    s_per_day<-(60/input$bins)*modulo_tau
    
    raw<-df[,2:length(df[1,])]
    raw_mean<-as.matrix(rowMeans(raw))
    
    raw<-cbind(raw,raw_mean)
    time_series_phase<-as.matrix(df[,1])
    
    raw_list<-list()
    
    for (i in 1:length(raw[1,])){
      raw_list[[i]]<-t(as.matrix(rollapply(raw[,i],width=s_per_day*input$nplot,by=s_per_day,as.numeric)))
    }
    
    ind_plot<-list()
    yy<-do.call(rbind,replicate(input$nplot,matrix(time_series_phase[1:((60/input$bins)*modulo_tau),1]),simplify=FALSE))
    zz<-dim(raw_list[[1]])
    yyy<-do.call(cbind, replicate(zz[[2]],yy,simplify=FALSE))
    for (i in 1:length(raw_list)){
      a<-raw_list[[i]]
      ind_plot[[i]]<-plot_ly(x=seq(1:(s_per_day*input$nplot)),
                             y=seq(1:(length(a[1,]))),
                             z=t(raw_list[[i]]),
                             text=t(yyy),
                             colors=colorRamp(c("white","darkblue")),
                             # colors=colorRamp(c("black","cyan","lawngreen")),
                             type="heatmap",
                             zauto=FALSE,
                             zmin=0,
                             zmax=input$max_z,
                             showscale=FALSE
      )%>%
        add_segments(x=c(seq(s_per_day,s_per_day*input$nplot,
                             by=s_per_day)),
                     xend=c(seq(s_per_day,s_per_day*input$nplot,
                                by=s_per_day)),
                     y=1,yend=length(a[1,])+1,
                     mode="lines",
                     line=list(color="black"))%>%
        layout(title=i,xaxis=list(title="time index"),
               yaxis=list(title="days",
                          autorange="reversed",
                          tickmode="array"),
                          # tickvals=seq(1,(length(a[1,])+1),by=4),
                          # ticktext=seq(1,(length(a[1,])+1),by=4)),
               showlegend=FALSE)
    }
    
    pp<-subplot(ind_plot,nrows = 5,shareX = TRUE,shareY = TRUE)%>%
      layout(title='',
             showlegend=FALSE
      )
    pp
  })
  #########################################################################################
  output$all.per <- renderPlotly({
    req(input$file)
    df<-read.delim(input$file$datapath,
                   header=input$header,
                   sep=input$sep,
                   quote=input$quote)
    sr<-1/mins(input$bins)
    raw<-df[,2:length(df[1,])]
    raw_mean<-as.matrix(rowMeans(raw))
    raw<-cbind(raw,raw_mean)
    
    ind_data<-list()
    ind_plot<-list()
    
    for (i in 1:length(raw[1,])){
      if (input$permethod==1){
        ind_data[[i]]<-chi_sq_periodogram(raw[,i],period_range=c(hours(input$lowest),
                                                                 hours(input$highest)),
                                          sampling_rate=sr,alpha=input$alpha,
                                          time_resolution=mins(input$bins))
      } else if (input$permethod==2) {
        ind_data[[i]]<-ac_periodogram(raw[,i],period_range=c(hours(input$lowest),
                                                             hours(input$highest)),
                                      sampling_rate=sr,alpha=input$alpha)
      } else {
        ind_data[[i]]<-ls_periodogram(raw[,i],period_range=c(hours(input$lowest),
                                                             hours(input$highest)),
                                      sampling_rate=sr,alpha=input$alpha)
      }
    }
    
    for (i in 1:length(ind_data)){
      a<-ind_data[[i]]
      ind_plot[[i]]<-plot_ly(x=a$period/3600,
                             y=a$power,
                             name=i,
                             # hoverinfo=text,
                             type="scatter",
                             mode="lines",
                             line=list(color="black", width = 2),
                             source = "period_power"
      )%>%
        add_trace(y=a$signif_threshold,
                  type="scatter",
                  mode="lines",
                  line=list(color="red", width = 2)
        )%>%
        layout(title=paste("C",i),xaxis=list(title="period"),
               yaxis=list(title="power",
                          tickmode="array"),
               showlegend=FALSE)
    }
    pp<-subplot(ind_plot,nrows = 5,shareX = TRUE,shareY = TRUE)%>%
      layout(title='',
             showlegend=FALSE
      )
    pp
    
  })
  #########################################################################################
  period_power<-matrix()
  #########################################################################################
  output$dataTable.period_power <- renderTable({
    d<-event_data("plotly_click",source = "period_power")
    period_power <<- matrix(c(period_power,d$x, d$y),nrow = 2)
  })
  #########################################################################################
  output$acto <- renderPlotly({
    req(input$file)
    df<-read.delim(input$file$datapath,
                   header=input$header,
                   sep=input$sep,
                   quote=input$quote)
    
    modulo_tau<-input$modulotau
    bin=input$bins
    s_per_day<-(60/bin)*modulo_tau
    nplot=input$nplot_ind
    
    raw_mean<-as.matrix(rowMeans(df[,-c(1)]))
    raw_proc<-cbind(df,raw_mean)
    colnames(raw_proc)<-NULL
    
    raw_pre<-as.matrix(raw_proc[,1+input$ind_actogram])
    dummy<-matrix(0,nrow=s_per_day*(nplot-1),ncol=1)
    raw<-rbind(dummy,raw_pre)
    time_series_phase<-as.matrix(df[,1])
    
    raw_list<-t(as.matrix(rollapply(raw[,1],width=s_per_day*nplot,by=s_per_day,as.numeric)))
    a<-raw_list
    plots<-list()
    
    for (i in 1:length(a[1,])){
      plots[[i]]<-plot_ly(
        y=a[,i],
        type="bar",
        marker=list(color="darkblue"),
        source = "acto_phases"
      )%>%
        layout(
          showlegend=F,
          yaxis=list(title=i-(nplot-1),
            showticklabels=FALSE,
            showgrid=FALSE,
            range=c(0,input$threshold*max(raw))
          ),
          barmode="stack",
          bargap=0
        )
    }
    
    s<-subplot(plots,
               nrows = length(plots),
               shareX = TRUE,titleY = T,
               margin=0.0)%>%
      layout(
        xaxis=list(
          title="time index",
          autotick = FALSE,
          ticks = "outside",
          tick0 = 0,
          dtick = (60/bin)*6,
          ticklen = 10,
          tickwidth = 4
        ),
        plot_bgcolor="transparent",
        paper_bgcolor="transparent")
  })
  #########################################################################################
  phase<-matrix()
  #########################################################################################
  output$dataTable.time_index <- renderTable({
    d<-event_data("plotly_click",source = "acto_phases")
    phase <<- matrix(c(phase, ((d$x * input$bins)/60)+input$first_time,d$curveNumber),nrow = 2)
  })
  #########################################################################################
  output$period <- renderPlotly({
    req(input$file)
    df<-read.delim(input$file$datapath,
                   header=input$header,
                   sep=input$sep,
                   quote=input$quote)

    modulo_tau<-input$modulotau
    bin=input$bins
    s_per_day<-(60/bin)*modulo_tau
    nplot=input$nplot
    
    raw_mean<-as.matrix(rowMeans(df[,-c(1)]))
    raw_proc<-cbind(df,raw_mean)
    colnames(raw_proc)<-NULL
    
    raw<-as.matrix(raw_proc[,1+input$ind_actogram])
    
    sr<-1/mins(input$bins)
    
    if (input$permethod==1){
      ind_data<-chi_sq_periodogram(raw[,1],period_range=c(hours(input$lowest),
                                                               hours(input$highest)),
                                        sampling_rate=sr,alpha=input$alpha,
                                        time_resolution=mins(input$bins))
    } else if (input$permethod==2) {
      ind_data<-ac_periodogram(raw[,1],period_range=c(hours(input$lowest),
                                                           hours(input$highest)),
                                    sampling_rate=sr,alpha=input$alpha)
    } else {
      ind_data<-ls_periodogram(raw[,1],period_range=c(hours(input$lowest),
                                                           hours(input$highest)),
                                    sampling_rate=sr,alpha=input$alpha)
    }
    
    ind_plot<-plot_ly(x=ind_data$period/3600,
                           y=ind_data$power,
                           name="",
                           # hoverinfo=text,
                           type="scatter",
                           mode="lines",
                           line=list(color="black", width = 2)
    )%>%
      add_trace(y=ind_data$signif_threshold,
                type="scatter",
                mode="lines",
                line=list(color="red", width = 2)
      )%>%
      layout(title="",xaxis=list(title="period"),
             yaxis=list(title="power",
                        tickmode="array"),
             showlegend=FALSE)
    ind_plot
  
  })
  #########################################################################################
  raw_pro<-matrix()
  #########################################################################################
  output$raw_profiles <- renderTable({
    req(input$file)
    df<-read.delim(input$file$datapath,
                   header=input$header,
                   sep=input$sep,
                   quote=input$quote)
    
    modulo_tau<-input$modulotau
    bin=input$bins
    s_per_day<-(60/bin)*modulo_tau
    
    raw<-df[1:((floor(length(df[,1])/s_per_day))*s_per_day),-c(1)]
    
    for_profile<-matrix(0,nrow=s_per_day,ncol=length(raw[1,]))
    for (i in 1:length(raw[1,])){
      a=Reshape(raw[,i],s_per_day)
      mean_a<-as.matrix(rowMeans(a))
      for_profile[,i]<-mean_a
    }
    # x<-aggregate(raw[,2:length(raw[1,])],by=list(raw[,1]),FUN=mean)
    raw_pro <<- for_profile
  })
  #########################################################################################
  output$raw_prof <- renderPlotly({
    
    req(input$file)
    df<-read.delim(input$file$datapath,
                   header=input$header,
                   sep=input$sep,
                   quote=input$quote)
    
    modulo_tau<-input$modulotau
    bin=input$bins
    s_per_day<-(60/bin)*modulo_tau
    
    raw<-df[1:((floor(length(df[,1])/s_per_day))*s_per_day),-c(1)]
    
    x<-matrix(0,nrow=s_per_day,ncol=length(raw[1,]))
    for (i in 1:length(raw[1,])){
      a=Reshape(raw[,i],s_per_day)
      mean_a<-as.matrix(rowMeans(a))
      x[,i]<-mean_a
    }
    # raw<-df[,-c(1,2,4:10)]
    # 
    # x<-aggregate(raw[,2:length(raw[1,])],by=list(raw[,1]),FUN=mean)
    
    pro_plots<-list()
    for (i in 1:length(raw[1,])){
      
      pro_plots[[i]]<-plot_ly(x=1:s_per_day,
                              y=x[,i],
                              name=i,
                              text=df[1:s_per_day,1],
                              hoverinfo=text,
                              type="scatter",
                              mode="lines",
                              line=list(color="darkblue", width = 2)
      )%>%
        
        layout(title="",xaxis=list(title="time index"),
               yaxis=list(title="value/bin",
                          tickmode="array"),
               showlegend=FALSE)
    }
    pp<-subplot(pro_plots,nrows = 4,shareX = TRUE,shareY = TRUE)%>%
      layout(title='',
             showlegend=FALSE
      )
    pp
  })

  ########################################################################################
  prop_pro<-matrix()
  
  output$prop_profiles <- renderTable({
    req(input$file)
    df<-read.delim(input$file$datapath,
                   header=input$header,
                   sep=input$sep,
                   quote=input$quote)
    
    modulo_tau<-input$modulotau
    bin=input$bins
    s_per_day<-(60/bin)*modulo_tau
    
    raw<-df[1:((floor(length(df[,1])/s_per_day))*s_per_day),-c(1)]
    
    prop_profile<-matrix(0,nrow=s_per_day,ncol=length(raw[1,]))
    
    for (i in 1:length(raw[1,])){
      a=Reshape(raw[,i],s_per_day)
      x=matrix(colSums(a,na.rm = TRUE),nrow=1)
      z<-matrix(0,nrow=s_per_day,ncol=length(a[1,]))
      for (k in 1:length(a[,1])){
        for (l in 1:length(a[1,])){
          z[k,l]<-a[k,l]/x[1,l]
        }
      }
      mean_a<-as.matrix(rowMeans(z,na.rm = TRUE))
      prop_profile[,i]<-mean_a
    }

    prop_pro <<- prop_profile
  })
  #########################################################################################  
  output$prop_prof <- renderPlotly({
    
    req(input$file)
    df<-read.delim(input$file$datapath,
                   header=input$header,
                   sep=input$sep,
                   quote=input$quote)
    
    modulo_tau<-input$modulotau
    bin=input$bins
    s_per_day<-(60/bin)*modulo_tau
    
    raw<-df[1:((floor(length(df[,1])/s_per_day))*s_per_day),-c(1)]
    
    prop_profile<-matrix(0,nrow=s_per_day,ncol=length(raw[1,]))
    
    for (i in 1:length(raw[1,])){
      a=Reshape(raw[,i],s_per_day)
      x=matrix(colSums(a,na.rm = TRUE),nrow=1)
      z<-matrix(0,nrow=s_per_day,ncol=length(a[1,]))
      for (k in 1:length(a[,1])){
        for (l in 1:length(a[1,])){
          z[k,l]<-a[k,l]/x[1,l]
        }
      }
      mean_a<-as.matrix(rowMeans(z,na.rm = TRUE))
      prop_profile[,i]<-mean_a
    }
    x=prop_profile
    # raw<-df[,-c(1,2,4:10)]
    # 
    # x<-aggregate(raw[,2:length(raw[1,])],by=list(raw[,1]),FUN=mean)
    
    pro_plots<-list()
    for (i in 1:length(raw[1,])){
      
      pro_plots[[i]]<-plot_ly(x=1:s_per_day,
                              y=x[,i],
                              name=i,
                              text=df[1:s_per_day,1],
                              hoverinfo=text,
                              type="scatter",
                              mode="lines",
                              line=list(color="darkblue", width = 2)
      )%>%
        
        layout(title="",xaxis=list(title="time index"),
               yaxis=list(title="value/bin",
                          tickmode="array"),
               showlegend=FALSE)
    }
    pp<-subplot(pro_plots,nrows = 4,shareX = TRUE,shareY = TRUE)%>%
      layout(title='',
             showlegend=FALSE
      )
    pp
  })
  
  ########################################################################################
  output$mean_raw_prof <- renderPlotly({
    
    req(input$file)
    df<-read.delim(input$file$datapath,
                   header=input$header,
                   sep=input$sep,
                   quote=input$quote)
    
    modulo_tau<-input$modulotau
    bin=input$bins
    s_per_day<-(60/bin)*modulo_tau
    
    raw<-df[1:((floor(length(df[,1])/s_per_day))*s_per_day),-c(1)]
    
    x<-matrix(0,nrow=s_per_day,ncol=length(raw[1,]))
    for (i in 1:length(raw[1,])){
      a=Reshape(raw[,i],s_per_day)
      mean_a<-as.matrix(rowMeans(a))
      x[,i]<-mean_a
    }
    
    xx<-as.matrix(rowMeans(x[,1:length(x[1,])]))
    
    p<-plot_ly(x=1:s_per_day,
               y=xx[,1],
               type="scatter",
               mode="lines",
               line=list(color="darkblue", width = 2),
               text=paste("Phase: ",df[1:s_per_day,1],sep=""),
               hoverinfo=text
      )%>%
      
      layout(title="",xaxis=list(title="time index"),
             yaxis=list(title="value/bin",
                        tickmode="array"),
             showlegend=FALSE)
    
    p
  })
  #########################################################################################
  output$mean_prop_prof <- renderPlotly({
    
    req(input$file)
    df<-read.delim(input$file$datapath,
                   header=input$header,
                   sep=input$sep,
                   quote=input$quote)
    
    modulo_tau<-input$modulotau
    bin=input$bins
    s_per_day<-(60/bin)*modulo_tau
    
    raw<-df[1:((floor(length(df[,1])/s_per_day))*s_per_day),-c(1)]
    
    prop_profile<-matrix(0,nrow=s_per_day,ncol=length(raw[1,]))
    
    for (i in 1:length(raw[1,])){
      a=Reshape(raw[,i],s_per_day)
      x=matrix(colSums(a,na.rm = TRUE),nrow=1)
      z<-matrix(0,nrow=s_per_day,ncol=length(a[1,]))
      for (k in 1:length(a[,1])){
        for (l in 1:length(a[1,])){
          z[k,l]<-a[k,l]/x[1,l]
        }
      }
      mean_a<-as.matrix(rowMeans(z,na.rm = TRUE))
      prop_profile[,i]<-mean_a
    }
    x=prop_profile
    
    xx<-as.matrix(rowMeans(x[,1:length(x[1,])]))
    
    p<-plot_ly(x=1:s_per_day,
               y=xx[,1],
               type="scatter",
               mode="lines",
               line=list(color="darkblue", width = 2),
               text=paste("Phase: ",df[1:s_per_day,1],sep=""),
               hoverinfo=text
    )%>%
      
      layout(title="",xaxis=list(title="time index"),
             yaxis=list(title="value/bin",
                        tickmode="array"),
             showlegend=FALSE)
    
    p
  })
  #########################################################################################
  output$rose <- renderPlotly({
    req(input$file)
    df<-read.delim(input$file$datapath,
                   header=input$header,
                   sep=input$sep,
                   quote=input$quote)
    
    modulo_tau<-input$modulotau
    bin=input$bins
    s_per_day<-(60/bin)*modulo_tau
    
    raw<-df[1:((floor(length(df[,1])/s_per_day))*s_per_day),-c(1)]
    
    x<-matrix(0,nrow=s_per_day,ncol=length(raw[1,]))
    for (i in 1:length(raw[1,])){
      a=Reshape(raw[,i],s_per_day)
      mean_a<-as.matrix(rowMeans(a))
      x[,i]<-mean_a
    }
    
    xx<-as.matrix(rowMeans(x[,1:length(x[1,])]))
    
    for_profile<-cbind(x,xx)
    
    theta<-as.matrix(df[1:s_per_day,1]*360/modulo_tau)
    
    plots<-plot_ly()%>%
      layout(showlegend=FALSE,
        angularaxis=list(
          # rotation=90,
          direction='counterclockwise'
          # rotation=90
        )
      )
    for (j in 1:length(for_profile[,1])){
      x=for_profile[j,input$ind_actogram_rose]
      y=theta[j,1]
      plots<-add_trace(plots,
                       r=c(0,x,x,0),
                       theta=c(0,y-((bin/60)*360/modulo_tau),y,0),
                       type='scatterpolar',
                       mode="lines",
                       line=list(color="black"),
                       fill='toself',
                       fillcolor=rgb(1,0,0,0.6)
      )
    }
    
    plots
  })
  #########################################################################################
  output$com <- renderPlotly({
    req(input$file)
    df<-read.delim(input$file$datapath,
                   header=input$header,
                   sep=input$sep,
                   quote=input$quote)
    
    modulo_tau<-input$modulotau
    bin=input$bins
    s_per_day<-(60/bin)*modulo_tau
    
    raw<-df[1:((floor(length(df[,1])/s_per_day))*s_per_day),-c(1)]
    
    x<-matrix(0,nrow=s_per_day,ncol=length(raw[1,]))
    for (i in 1:length(raw[1,])){
      a=Reshape(raw[,i],s_per_day)
      mean_a<-as.matrix(rowMeans(a))
      x[,i]<-mean_a
    }
    
    theta<-as.matrix(df[1:s_per_day,1]*360/modulo_tau)
    
    sin_theta <- as.matrix(sin(theta*(pi/180)))
    cos_theta <- as.matrix(cos(theta*(pi/180)))
    fsintheta <- matrix(0,nrow=length(x[,1]),ncol=length(x[1,]))
    fcostheta <- matrix(0,nrow=length(x[,1]),ncol=length(x[1,]))
    for (i in 1:length(x[,1])){
      for (j in 1:length(x[1,])){
        fsintheta[i,j] <- sin_theta[i,1]*x[i,j]
        fcostheta[i,j] <- cos_theta[i,1]*x[i,j]
      }
    }
    sum_fsintheta <- matrix(colSums(fsintheta),nrow=1)
    sum_fcostheta <- matrix(colSums(fcostheta),nrow=1)
    
    n_samples<-matrix(colSums(x),nrow=1)
    X <- matrix(0,nrow=1,ncol=length(x[1,]))
    Y <- matrix(0,nrow=1,ncol=length(x[1,]))
    mean_theta <- matrix(0,nrow=1,ncol=length(x[1,]))
    mean_r <- matrix(0,nrow=1,ncol=length(x[1,]))
    
    for (i in 1:length(n_samples[1,])){
      X[1,i] <- sum_fcostheta[1,i]/n_samples[1,i]
      Y[1,i] <- sum_fsintheta[1,i]/n_samples[1,i]
      if (X[1,i]<0){
        mean_theta[1,i] <- (pi + atan(Y[1,i]/X[1,i])) * 180/pi
      } else {
        mean_theta[1,i] <- (atan(Y[1,i]/X[1,i])) * 180/pi
      }
      mean_r[1,i] <- sqrt((X[1,i]^2) + (Y[1,i]^2))
    }
    plots<-plot_ly(
      r = as.vector(mean_r),
      theta = as.vector(mean_theta),
      type='scatterpolar',
      mode="markers",
      marker=list(color="brown")
      # fill='toself',
      # fillcolor=rgb(1,0,0,0.6)
    )%>%
      layout(showlegend=FALSE,
             angularaxis=list(
               # rotation=90,
               direction='counterclockwise'
               # rotation=90
             )
      )
    plots
  })
  
  #########################################################################################
  phase_com<-matrix()
  
  output$com_phases <- renderTable({
    req(input$file)
    df<-read.delim(input$file$datapath,
                   header=input$header,
                   sep=input$sep,
                   quote=input$quote)
    
    modulo_tau<-input$modulotau
    bin=input$bins
    s_per_day<-(60/bin)*modulo_tau
    
    raw<-df[1:((floor(length(df[,1])/s_per_day))*s_per_day),-c(1)]
    
    x<-matrix(0,nrow=s_per_day,ncol=length(raw[1,]))
    for (i in 1:length(raw[1,])){
      a=Reshape(raw[,i],s_per_day)
      mean_a<-as.matrix(rowMeans(a))
      x[,i]<-mean_a
    }
    
    theta<-as.matrix(df[1:s_per_day,1]*360/modulo_tau)
    
    sin_theta <- as.matrix(sin(theta*(pi/180)))
    cos_theta <- as.matrix(cos(theta*(pi/180)))
    fsintheta <- matrix(0,nrow=length(x[,1]),ncol=length(x[1,]))
    fcostheta <- matrix(0,nrow=length(x[,1]),ncol=length(x[1,]))
    for (i in 1:length(x[,1])){
      for (j in 1:length(x[1,])){
        fsintheta[i,j] <- sin_theta[i,1]*x[i,j]
        fcostheta[i,j] <- cos_theta[i,1]*x[i,j]
      }
    }
    sum_fsintheta <- matrix(colSums(fsintheta),nrow=1)
    sum_fcostheta <- matrix(colSums(fcostheta),nrow=1)
    
    n_samples<-matrix(colSums(x),nrow=1)
    X <- matrix(0,nrow=1,ncol=length(x[1,]))
    Y <- matrix(0,nrow=1,ncol=length(x[1,]))
    mean_theta <- matrix(0,nrow=1,ncol=length(x[1,]))
    mean_r <- matrix(0,nrow=1,ncol=length(x[1,]))
    
    for (i in 1:length(n_samples[1,])){
      X[1,i] <- sum_fcostheta[1,i]/n_samples[1,i]
      Y[1,i] <- sum_fsintheta[1,i]/n_samples[1,i]
      if (X[1,i]<0){
        mean_theta[1,i] <- (pi + atan(Y[1,i]/X[1,i])) * 180/pi
      } else {
        mean_theta[1,i] <- (atan(Y[1,i]/X[1,i])) * 180/pi
      }
      mean_r[1,i] <- sqrt((X[1,i]^2) + (Y[1,i]^2))
    }
    
    phase_com <<- rbind(mean_theta,mean_r)
  })
  
  #########################################################################################
  datasetInput <- reactive({
    switch(input$dataset,
           "raw average profiles" = raw_pro,
           "prop average profiles" = prop_pro,
           "phases from actogram figures" = phase,
           "all period power" = period_power,
           "CoM" = phase_com)
  })
  
  output$table <- renderTable({
    datasetInput()
  })
  
  output$downloadData <- downloadHandler(
    filename = function(){
      paste(input$dataset,input$`name_your_plots`,".csv",sep="")
    },
    content = function(file){
      write.csv(datasetInput(),file,row.names=FALSE)
    }
  )
}
)
