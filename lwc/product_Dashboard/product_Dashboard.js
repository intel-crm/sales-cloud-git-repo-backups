import { LightningElement,track } from 'lwc';
import getProdData from '@salesforce/apex/Product_RetrieveProdData.getProdData';
import getLastRefreshDate from '@salesforce/apex/Product_RetrieveProdData.getLastRefreshDate';
import getReportId from '@salesforce/apex/Product_RetrieveProdData.getReportId';
import { NavigationMixin } from 'lightning/navigation';
export default class ProductDashboard extends NavigationMixin(LightningElement)  {
    @track prodData=[];
    @track listViewName;
    @track lastRefreshDate;
    @track vphReportId;
    @track vplchReportId;
    @track reportName;
    @track reportIds;
    @track reportId;

    connectedCallback(){
        this.retrieveData();
        this.getLRD();
        this.getRId();
    }

    retrieveData(){
        getProdData()
        .then(data => {
            if(data){
                console.log('data'+data);
                for (let key in data) {
                    this.prodData.push({value:data[key], key: key});
                }
            }else if(error){
                console.log(error);
            }
        });
    }

    getLRD(){
        getLastRefreshDate()
        .then(data => {
            if(data){
                this.lastRefreshDate = data;
            }else if(error){
                console.log(error);
            }
        });
    }

    getRId(){
        getReportId()
        .then(data=>{
            if(data){
                this.reportIds = data;
                this.vphReportId = this.reportIds[0];
                this.vplchReportId = this.reportIds[1];
            }
            else if (error){
                console.log(error);
            }
        });
    }
    setListViewFilter(event){
        if(event.target.dataset.id == 'Sales Active Products'){
            this.listViewName = 'Sales_Active_Products';
            this.viewRecordsList();
        }
        else if(event.target.dataset.id == 'IPS Active Products'){
            this.listViewName = 'IPS_Active_Products';
            this.viewRecordsList();
        }
        else if(event.target.dataset.id =='VPH Product Types'){
            this.reportId = this.vphReportId;
            this.viewReport();
        }
        else if(event.target.dataset.id =='VPLCH Product Types'){
            this.reportId = this.vplchReportId;
            this.viewReport();
        }
        else if(event.target.dataset.id =='Products With Available for New Designs'){
            this.listViewName ='Products_With_Available_for_New_Designs';
            this.viewRecordsList();
        }
        else if(event.target.dataset.id =='Products With IQR Visible Flag'){
            this.listViewName ='Products_With_IQR_Visible_Flag';
            this.viewRecordsList();
        }
        else if(event.target.dataset.id =='Products With DDR Eligible'){
            this.listViewName ='Products_With_DDR_Eligible';
            this.viewRecordsList();
        }
        else if(event.target.dataset.id =='Products With IPS Visible Flag'){
            this.listViewName ='Products_With_IPS_Visible_Flag';
            this.viewRecordsList();
        }
        
        console.log('rep name --- '+this.listViewName);
        
    }
    viewRecordsList() {        
        this[ NavigationMixin.Navigate ]({
            type: 'standard__objectPage',
            attributes: {                
                objectApiName: 'Product2',
                actionName: 'list'
            },
            state: {
                filterName: this.listViewName
            }
        });
    }
    viewReport(){
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.reportId,
                objectApiName: 'Report',
                actionName: 'view'
            }
        });
    }
}