import { LightningElement, api, track,wire } from 'lwc';
import displayPointsData from '@salesforce/apex/PRM_AccountActvityOverview.displayPointsData'
import total_SalesData from '@salesforce/label/c.PRM_totalSalesData';
import total_TrainingCredits from '@salesforce/label/c.PRM_totalTrainingCredits';
import total_TrainedResource from '@salesforce/label/c.PRM_totaltrainedResources';
import total_ApprovedOffering from '@salesforce/label/c.PRM_Total_Approved_Offering';
import NumberOfEmployees from '@salesforce/label/c.PRM_No_of_Employees';
import totalApprovedSol from '@salesforce/label/c.PRM_Total_Approved_Solutions';
import ispublished from '@salesforce/label/c.PRM_IsPublished';
import isNotpublished from '@salesforce/label/c.PRM_IsNotPublished';
import TotalApprovedOffering from '@salesforce/label/c.PRM_Total_Approved_Offering';
import publishedStorefrnt from '@salesforce/label/c.PRM_Published_Storefront';
import ClickHereForInfo from '@salesforce/label/c.PRM_ClickForInfo';
import getPageURL from '@salesforce/apex/PRM_External_Objects_Data.getPageURL';
import getSalesPageURL from '@salesforce/apex/PRM_External_Objects_Data.pageUrlSales';
import link from '@salesforce/label/c.PRM_Training_Report_Link';
import headerTraining from '@salesforce/label/c.PRM_Training_DashboardRen_Label';
import headerSales from '@salesforce/label/c.PRM_Sales_Dashboard_Label';
import showLink from '@salesforce/apex/PRM_RenewalStatus.showLink';
import getAccount from '@salesforce/apex/PRM_AccountActvityOverview.getAccountId';
export default class prm_renewalDashboard extends LightningElement {
    @api vxdynamiccont;
    @api content2;
    @track totalSalesData = total_SalesData;
    @track totalTrainingCredits = total_TrainingCredits;
    @track totalTrainedResources = total_TrainedResource;
    @track totalApprovedOffering = total_ApprovedOffering
    @track total_SalesDatanbr;
    @track total_TrainingCreditsnbr;
    @track total_TrainedResource = 0;
    @track total_ApprovedOffering = 0;
    @track totalsaleswithDollar;
    @track isLoaded = false;
    @track isPublishedStorefront;
    @track publishedStorefrontText = publishedStorefrnt;
    @track isPublishedText = ispublished;
    @track isNotPublishedText = isNotpublished;
    @track total_MaxEmployees;
    @track totalApprovedSolutions;
    linkLbl = link;
    headerLbl = headerTraining;
    headerSalesLbl = headerSales;
    @track totalApprovedSol=totalApprovedSol;
    @track NumberOfEmployees = NumberOfEmployees;
    @track TotalApprovedOffering = TotalApprovedOffering;
    @track pageUrl;
    @track pageUrlSales;
    @track error2;
    @track accId;
    @track acrId = [];
    @track vxdata;
    accountIdDis;
    @track valueexdata;
    @track valueexdata1;
    @track isLoading = false;
    @track showSpinner = true;
    @track showsalesLink = true;
    label = {
      ClickHereForInfo,
      ispublished,
      isNotpublished

    };

    connectedCallback() {
      this.getaccountDetails();
      console.log('Data from Aura without parse'+this.vxdynamiccont);
      this.valueexdata = JSON.parse(this.vxdynamiccont);
      //this.valueexdata1 = JSON.parse(this.content2);
      console.log('Data from Aura'+this.valueexdata);
      this.getEmployeeACR();
      getPageURL().then((result) => {
        console.log('page url'+this.pageUrl);
        this.pageUrl = result;
        this.error2 = undefined;
        }).catch((err) => {
            console.log('error url'+this.pageUrl);
            this.error2 = err;
            this.pageUrl = '';
        });
      
        getSalesPageURL().then((result) => {
          console.log('page url'+this.pageUrlSales);
          this.pageUrlSales = result;
          this.error2 = undefined;
          }).catch((err) => {
              console.log('error url'+this.pageUrlSales);
              this.error2 = err;
              this.pageUrlSales = '';
          });  
    }
    getaccountDetails(){
      getAccount().then(result =>{
        if(result){
            this.accId = result;
            console.log('AccountId----->'+JSON.stringify(result));
            this.displayMethod(this.accId);
            
        }
        else{
        //  this.error = error;
          console.log('error---->');
        }
      })
    }

    displayMethod(accountIdDis) { 
        console.log('AccountIdDis--->'+accountIdDis);
        this.isLoading = true;
        displayPointsData({ accID:  accountIdDis}).then(result => {
            if (result) {
                this.isLoaded = true;
                console.log('result -->' + JSON.stringify(result));
                console.log('recordId----->'+this.recordId);
                this.totalsaleswithDollar = '$';
                if(result.totalSalesDataPrevPeriod || result.totalTrainingCreditsPrevPeriod || result.totalApprovedSolutions){
                  this.total_SalesDatanbr = result.totalSalesDataPrevPeriod;
                  this.total_TrainingCreditsnbr =result.totalTrainingCreditsPrevPeriod;
                  this.totalApprovedSolutions= result.totalApprovedSolutions;
                }else{
                  this.total_SalesDatanbr = 0;
                  this.total_TrainingCreditsnbr =0;
                  this.totalApprovedSolutions= 0;
                }
                //this.total_SalesDatanbr = result.totalSalesData? totalSalesData:0;
              //  this.total_TrainingCreditsnbr =result.totalTrainingCredits;
               // this.total_TrainedResource = this.convertNumber(result.totalTrainedResources,true);
                //this.total_ApprovedOffering = this.convertNumber(result.totalApprovedOffering, true);
              //  this.ispublishedStorefront = result.publishedStorefront;
               // this.total_MaxEmployees = this.convertNumber(result.totalTrainedResourcesMax, true);
              //  this.totalApprovedSolutions= result.totalApprovedSolutions;
                console.log('total_SalesDatanbr-->'+JSON.stringify(this.total_SalesDatanbr.value));
                console.log('total_SalesDatanbr-->'+JSON.stringify(this.trainedCurrentList));
                console.log('totalApprovedSolutions-->'+JSON.stringify(this.totalApprovedSolutions));
                this.isLoading = false;
                this.showSpinner = false;
                
            } 
        })
        .catch(error => {
            console.log('displayPointsData.error -->' + JSON.stringify(error));
            this.isLoading = false;
        });
    }

  getEmployeeACR(){
    showLink().then(result =>{
      if(result){
          this.acrId = result;
          this.acrId.forEach(element => {
            if(element === 'Employee' && this.acrId.length==1){
              this.showsalesLink =false;
              console.log('Showsaleslink inside if--->'+this.showsalesLink);
            }
            console.log('Showsaleslink outside if--->'+this.showsalesLink);
          })
        }
      else{
        console.log('error---->');
      }
    })
  }
   
  /*convertNumber(value, convert) {
        // Default is no conversion
        const converted = {
          decimals: 0,
          text: '',
          value,
        };
  
        if (convert) {
          if (value >= 1000 && value < 1000000) {
            // Convert the number to the "xxx K" format
            converted.decimals = 0;
            converted.text = '';
            converted.value = value / 1000;
          } else if (value >= 1000000 && value < 1000000000) {
            // Convert the number to the "xxx M" format
            converted.decimals = 0;
            converted.text = '';
            converted.value = value / 1000000;
          } else if (value >= 1000000000){
            // Convert the number to the "xxx B" format
            converted.decimals = 0;
            converted.text = '';
            converted.value = value / 1000000000;  
          }
        }
        return converted;
      } */
         
}