import { LightningElement,track,api } from 'lwc';
import fetchReports_new from "@salesforce/apex/UCD_AccountTypeDQ.combineChart_new";
import dashdata from "@salesforce/apex/UCD_AccountTypeDQ.dashdata";
import dashdata_core from "@salesforce/apex/UCD_AccountTypeDQ.dashdata_core";

export default class Screendashboard extends LightningElement {

    oppValues;
    @track loaded=true;

    @track ipachartConfiguration;
    @track ipachartConfigurationcore;
    @track aechartConfiguration;
    @track aechartConfigurationcore;
    @track psgchartConfiguration;
    @track psgchartConfigurationcore;

    @track ipaReport =[];
    @track ipaReportcore =[];
    @track aeReport =[];
    @track aeReportcore =[];
    @track psgReport =[];
    @track psgReportcore =[];

    @track ipasize;
    @track ipaCoreSize;
    @track aesize;
    @track aeCoreSize;
    @track psgsize;
    @track psgCoreSize;

    @track showreports = false;
    @track showreportsae = false;
    @track showreportspsg = false;
    
    graphData(data){
      return {
        type: 'doughnut',
        data: data,
        options: {
            responsive: true,
            interaction: {
                mode: 'nearest'
            },
            legend: {
                display: true, 
                position: "right",
                fullWidth: true,                               
                labels: {boxWidth: 10,fontSize: 14},
                title: {display: true,text: "DQ Score"}
            },
            animation: {
              animateScale: true,
              animateRotate: true
            },
            title: {
              display: true,
              text: "Record count"
            }
          }
      };
    }

    graphSettings(setValues){
      return {
        labels: ['<25','25-50','50-75','75-100'],
        datasets: [{
          label: 'My First Dataset',
          data: setValues,
          backgroundColor: ['#F59623','#77B9F2','#F0E442','#4ED4CD'],
          hoverOffset: 4
        }]
      };
    }
    constructor(){
        super();

/////////////////////////////////////////////////////IPA//////////////////////////////////////
       fetchReports_new({type :'ipa'})
        .then((response) => {
            this.ipaReport=response;       
            this.ipasize=this.ipaReport.length;//8
            for(let i =0;i<response.length;i++){
              if(response[i].coreScore == 100){
                  this.ipaReportcore.push(response[i]);
              }
            }
            this.ipaCoreSize=this.ipaReportcore.length;//4           
            if(this.ipaReport && this.ipaReportcore){
              this.showreports = true;
            }

            dashdata({comwrap:this.ipaReport})
            .then((response1) => {             
                this.ipachartConfiguration = []; 
                const data = this.graphSettings(response1);
                this.ipachartConfiguration = this.graphData(data);
            })
            .catch((error) => {
                console.log('error',JSON.stringify(error));
                
              });

            dashdata_core({comwrap:this.ipaReport})
            .then((response1) => {
              
                this.ipachartConfigurationcore = [];
                const data = this.graphSettings(response1);
                this.ipachartConfigurationcore =this.graphData(data);

            })
            .catch((error) => {
                console.log('error',JSON.stringify(error));
                
            });
             this.loaded=false;
        })
        .catch((error) => {
            console.log('error',JSON.stringify(error));
            
        });

        /////////////////////////////////////////////////////A&E//////////////////////////////////////
        fetchReports_new({type :'a&e'})
        .then((response) => {
            this.aeReport=response;
            this.aesize=this.aeReport.length;
            for(let i =0;i<response.length;i++){
              if(response[i].coreScore == 100){
                  this.aeReportcore.push(response[i]);
              }
            }
           this.aeCoreSize=this.aeReportcore.length;
            if(this.aeReport && this.aeReportcore){
              this.showreportsae = true;
            }
            
            dashdata({comwrap:this.aeReport})
            .then((response1) => {
              
                this.aechartConfiguration = [];
                const data = this.graphSettings(response1);
                this.aechartConfiguration = this.graphData(data);          

            })
            .catch((error) => {
                console.log('error',JSON.stringify(error));
                
            });

            dashdata_core({comwrap:this.aeReport})
            .then((response1) => {
              
                this.aechartConfigurationcore = [];
                const data = this.graphSettings(response1);
                this.aechartConfigurationcore = this.graphData(data);

            })
            .catch((error) => {
                console.log('error',JSON.stringify(error));
                
            });
             this.loaded=false;
        })
        .catch((error) => {
            console.log('error',JSON.stringify(error));
            
        });
/////////////////////////////////////////////////////psg//////////////////////////////////////
       
        fetchReports_new({type :'psg'})
        .then((response) => {
            this.psgReport=response;
            this.psgsize=this.psgReport.length;
            for(let i =0;i<response.length;i++){
              if(response[i].coreScore == 100){
                  this.psgReportcore.push(response[i]);
              }
            }
            this.psgCoreSize=this.psgReportcore.length;
            if(this.psgReport && this.psgReportcore){
              this.showreportspsg = true;
            }
          
            dashdata({comwrap:this.psgReport})
            .then((response1) => {
              
                this.psgchartConfiguration = [];
                const data = this.graphSettings(response1);
                this.psgchartConfiguration = this.graphData(data);
            })
            .catch((error) => {
                console.log('error',JSON.stringify(error));
                
            });

            dashdata_core({comwrap:this.psgReport})
            .then((response1) => {
              
                this.psgchartConfigurationcore = [];
                const data = this.graphSettings(response1);
                this.psgchartConfigurationcore = this.graphData(data);
            })
            .catch((error) => {
                console.log('error',JSON.stringify(error));
                
            });

             this.loaded=false;
        })
        .catch((error) => {
            console.log('error',json.stringify(error));
            
        });
    }

    
    
   
 
}