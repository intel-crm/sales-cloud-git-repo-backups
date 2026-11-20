/* eslint-disable no-console */
import { LightningElement } from 'lwc';
//import getProductList from '@salesforce/apex/Sales_CreateLicenseController.getProductList';
//import getFaeUser from '@salesforce/apex/Sales_CreateLicenseController.getFaeUser';//added my me
/*import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createLic from '@salesforce/apex/Sales_CreateLicenseProvider.createLic';
import ProductNotSelcted from '@salesforce/label/c.ProductNotSelcted';
import ProductNotSelctedBeforeEditing from '@salesforce/label/c.ProductNotSelctedBeforeEditing';
import FixedNoSeat1 from '@salesforce/label/c.FixedNoSeat1';
import NoProducts from '@salesforce/label/c.NoProducts';
import T_C from '@salesforce/label/c.T_C';
import NoSeats0 from '@salesforce/label/c.NoSeats0';
import NoSeatsBlank from '@salesforce/label/c.Sales_noSeats_Error';
import ErrorMsg1 from '@salesforce/label/c.Sales_Signup_error_msg1';
import ErrorMsg2 from '@salesforce/label/c.Sales_Signup_error_msg2';
import ErrorMsg3 from '@salesforce/label/c.Sales_Signup_error_msg3';
import TermsCondition from '@salesforce/label/c.TermsCondition';
import Sales_ofseat from '@salesforce/label/c.Sales_ofseat';
import Sales_Maitenance_Exp from '@salesforce/label/c.Sales_Maitenance_Exp';
import Sales_License_Expiration from '@salesforce/label/c.Sales_License_Expiration';
import Sales_Product from '@salesforce/label/c.Sales_Product';
import { NavigationMixin } from 'lightning/navigation';*/
/********************************************
Component Name    : Sales_CreateLicense
Created Date  : Jun 2021
Function      : US981428, used for employee license

Modification Log :
Developer                 		Date                    Description
ananga.mohan.sen@accenture.com  21/06/2021				 US981428
************************************************************/

/*const columns=[
    { label: Sales_Product, fieldName: 'prodName' },
    { label: Sales_ofseat, fieldName: 'noSeats', editable: true,
    cellAttributes: {
		class: 'slds-text-color_success slds-text-title_caps'
	} },
    { label: Sales_Maitenance_Exp, fieldName: 'maintenenceExp' },
    { label: Sales_License_Expiration, fieldName: 'licExp'},
];*/
export default class Sales_CreateLicense extends LightningElement {
    /*@track buttonClicked=false;
    isload =false;
    isfaeuser=false;
    termandcondition=false;
    result;
    error;
    dataAvailable=false;
    columnsList=columns;
    selectedRows =[];
    changedNoSeats2=[];
    draftValues = [];
    selectedProd = [];
    errorProd=false;
    termsAccepted=false;
    //used to call generate license component
    licenseRecord=[];
    lic_id;
    licWebFlag;
    licActivationId;
    licensetypevalue;
     @track isFae=true ;
    primarycontact;
    tooltype;//added for tool type
    navigateToGenerateLic=false;
    @api tandCDescription;
    @api showTermsCheck = false;
    //toast message variables
    mode;
    title;
    message;
    variant;
    //labels
    label = {
        ProductNotSelcted,
        ProductNotSelctedBeforeEditing,
        FixedNoSeat1,
        NoProducts,
        T_C,
        NoSeats0,
        NoSeatsBlank,
        ErrorMsg1,
        Sales_Product,
        Sales_ofseat,
        Sales_Maitenance_Exp,
        Sales_License_Expiration,
        ErrorMsg2,
        ErrorMsg3,
        TermsCondition
    };
    TermsCondition_txt=this.label.TermsCondition;
    ///modal
    bShowModal;
    connectedCallback(){
        console.log('inside Connected callback');
      //  this.dataAvailable=false;
      //  this.isload=true;
        this.checkFaeUser();
       
    }
    closeModal(){
        this.bShowModal=false;
    }
    openModal(){
        this.bShowModal=true;
    }
    showTerms(){
        this.showTermsCheck = true;
    }
    licenseType='Employee';
    /********************************************
        Function      : wire method to get list of products
        Modification Log :
        Developer                 		Date                    Description
        ananga.mohan.sen@accenture.com  21/06/2021				 US981428
    ************************************************************/

    /*@wire(getProductList,{licenseType:'$licenseType'})
    getProductList({ error, data }) {
        if (data) {
            this.result = data;
            if(this.result.length>0){
            this.dataAvailable=true;
            this.isload=true;
            }
            else{
                this.isload= true;
                this.dataAvailable=false;
            }
             ///show error in the UI if no records
            this.error = undefined;
        } else if (error) {
            console.log('errors>>>'+error);
            this.error = error;
            this.result = undefined;
            this.dataAvailable=false;
            this.isload= true;
           
        }
      
    }*/
     /********************************************
        Function      : handle the selected row data
        Modification Log :
        Developer                 		Date                    Description
        ananga.mohan.sen@accenture.com  21/06/2021				 US981428
    ************************************************************/
    /*getSelectedRow(event){
        this.selectedRows = event.detail.selectedRows; 
        this.tandCDescription=this.selectedRows[0].TandC;
        console.log('selectedRows>>'+JSON.stringify(this.selectedRows));
        for (let i = 0; i < this.selectedRows.length; i++){
            this.selectedProd=[];
            this.selectedProd.push({
                licExp:this.selectedRows[i].licExp,
                licType:this.selectedRows[i].licType,
                maintenenceExp:this.selectedRows[i].maintenenceExp,
                noSeats:this.selectedRows[i].noSeats,
               // displayEditIcon:selectedRows[i].displayEditIcon,
                prodExtId:this.selectedRows[i].prodExtId,
                prodId:this.selectedRows[i].prodId,
                prodName:this.selectedRows[i].prodName,
                maxRehost:this.selectedRows[i].maxRehost,
                prodExtTempLicAllowed:this.selectedRows[i].prodExtTempLicAllowed,
                isEmployee:true
            });
        }
        console.log('selectedProd value after row select>>'+JSON.stringify(this.selectedProd)); 
        this.termandcondition=true;
    }
    /********************************************
        Function      : handle the  get license button click
        Modification Log :
        Developer                 		Date                    Description
        ananga.mohan.sen@accenture.com  21/06/2021				 US981428
    ************************************************************/
    /*handleClick(){
        this.buttonClicked=true;
        console.log('button'+this.buttonClicked);
        console.log('handleclick  string>>'+JSON.stringify(this.selectedProd));
        console.log('this.errorProd>>'+this.errorProd);
        let reqString=JSON.stringify(this.selectedProd);
        console.log('reqString>>' + reqString);
        console.log('handleclick json object>>'+JSON.parse(JSON.stringify(this.selectedProd)));
      // console.log('No of Seats>>'+this.selectedProd[0].noSeats);
        if(this.selectedProd.length===0){
            console.log('No item has selected');
            this.mode='dismissible';
            this.title='Error';
            if(this.errorProd){
                this.message=this.label.FixedNoSeat1;
            }
            else{
                this.message=this.label.ProductNotSelcted;
            }
            this.buttonClicked=false;
            this.variant='error';
            this.showErrorToast();
           
        }
        if(this.selectedProd[0].noSeats===undefined || this.selectedProd[0].noSeats===''){
            console.log('No item has selected>>>>');
            this.mode='dismissible';
            this.title='Error';
            this.message=this.label.NoSeatsBlank;
            this.buttonClicked=false;
            this.variant='error';
            this.showErrorToast();
        }
        else if(!this.termsAccepted){
            console.log('check box not checked'+this.termsAccepted);
            this.mode='dismissible';
            this.title='Error';
            this.message=this.label.T_C;
            this.buttonClicked=false;
            this.variant='error';
            this.showErrorToast();
        }
        else{
            this.buttonClicked=true;
        createLic({json:reqString})
        
            .then(result =>{
               this.licenseRecord=result;
               console.log('new license>>'+JSON.stringify(this.licenseRecord));
               this.licActivationId=this.licenseRecord.Sales_License_Activation_Code__c;
               this.lic_id=this.licenseRecord.Id;
               this.primarycontact=this.licenseRecord.Sales_License_Primary_Admin_Contact__c;
               this.tooltype=this.licenseRecord.Sales_License_Product__r.Core_Prod_Tool_Type_Nm__c; //added for tool type
               this.licensetypevalue=this.licenseRecord.Sales_Tool_License_Type__c;
               console.log('new lic id>>'+this.lic_id+'Activateion code>>'+this.licActivationId+
                                'primarycontact>>>'+this.primarycontact+'licensetypevalue>>>'+this.licensetypevalue);
               this.navigateToGenerateLic=true;
               this.openModal();
               
            })
            .catch(error =>{
                console.log('apex call error'+error);
            })
        }  

    }
     /********************************************
        Function      : handle the  edition of seat #
        Modification Log :
        Developer                 		Date                    Description
        ananga.mohan.sen@accenture.com  21/06/2021				 US981428
    ************************************************************/
    /*handleNoSeatsEdit(event){
        console.log('select row val>>'+JSON.stringify(this.selectedRows[0]));
        if(this.selectedRows[0]===undefined){
            //throw error if row not selcted but #seats edited
            this.mode='sticky';
            this.title='Error';
           // this.message='Please select a product before editing';
            this.message=this.label.ProductNotSelctedBeforeEditing;
            this.variant='error'
            this.showErrorToast();
            //alert('Please select the row before editing');
            //eval("$A.get('e.force:refreshView').fire();");
            setTimeout(function() {
                location.reload();
              }, 4000);   
        }
        
        else  {
            console.log('event.detail.draftValues>>>>'+event.detail.draftValues);
            this.changedNoSeats2=event.detail.draftValues;
            console.log('changedNoSeats2>>>'+JSON.stringify(this.changedNoSeats2[0].noSeats));
            //for loop with draft value
            console.log('select row val in else>>'+JSON.stringify(this.selectedRows[0]));
           
            for (let i = 0; i < this.selectedRows.length; i++){
                for(let j = 0; j < this.changedNoSeats2.length; j++){
                    //error for #seat not 1 and lic is fixed
                    if(this.selectedRows[i].licType==='FIXED' && this.changedNoSeats2[j].noSeats!=1){
                        this.errorProd=true;
                        this.selectedProd=[];
                        console.log('inside if, float but seats not 1');
                        this.mode='sticky';
                        this.title='Error';
                        //this.message='# of seats should be 1 if License type is Fixed';
                        this.message=this.label.FixedNoSeat1;
                        //FixedNoSeat1
                        this.variant='error'
                        this.showErrorToast();
                        break;
                     }
                     if(this.selectedRows[i].licType==='FIXED' && this.changedNoSeats2[j].noSeats==='1'){
                        this.errorProd=false;
                        console.log('this.errorProd--->'+this.errorProd);
                    }    

                      //error for #seat equals 0 
                     console.log('changed seats before error>>>'+this.changedNoSeats2[j].noSeats);
                    if(this.changedNoSeats2[j].noSeats==='0'){
                        this.selectedProd=[];
                        console.log('#seats is 0');
                        this.mode='sticky';
                        this.title='Error';
                        this.message=this.label.NoSeats0;
                        this.variant='error'
                        this.showErrorToast();
                        break;
                    }
                
                this.selectedProd=[]; 
                this.selectedProd.push({
                    licExp:this.selectedRows[i].licExp,
                    licType:this.selectedRows[i].licType,
                    maintenenceExp:this.selectedRows[i].maintenenceExp,
                    noSeats:this.changedNoSeats2[j].noSeats,
                   // displayEditIcon:selectedRows[i].displayEditIcon,
                    prodExtId:this.selectedRows[i].prodExtId,
                    prodId:this.selectedRows[i].prodId,
                    prodName:this.selectedRows[i].prodName,
                    maxRehost:this.selectedRows[i].maxRehost,
                    prodExtTempLicAllowed:this.selectedRows[i].prodExtTempLicAllowed,
                    isEmployee:true
                });
            }
            }
        
            
        }  
       console.log('selectedProd value after #seat changes>>'+JSON.stringify(this.selectedProd));       

    }
    /********************************************
        Function      : handle checkbox
        Modification Log :
        Developer                 		Date                    Description
        ananga.mohan.sen@accenture.com  21/06/2021				 US981428
    ************************************************************/
    /*handleTandC(event){
                if (event.target.checked)
                 {
                     this.termsAccepted=true;
                 }
                 else 
                 this.termsAccepted=false;

    }
     /********************************************
        Function      : generic toast message
        Modification Log :
        Developer                 		Date                    Description
        ananga.mohan.sen@accenture.com  21/06/2021				 US981428
    ************************************************************/
    /*showErrorToast() {
        const evt = new ShowToastEvent({
            mode:this.mode,
            title: this.title,
            message: this.message,
            variant: this.variant
           
        });
        this.dispatchEvent(evt);
    }
    /*checkFaeUser(){
            getFaeUser()
                .then((result) => {
                    console.log("isFae",+result);
                    if(result == true){
                        this.isFae=true;
                        this.isfaeuser=true;
                 }
                 else{
                    console.log("isFae line 322",+result);
                    this.isFae=false;
                    this.isfaeuser=true;
                 }
            });
        }*/
   
       
}