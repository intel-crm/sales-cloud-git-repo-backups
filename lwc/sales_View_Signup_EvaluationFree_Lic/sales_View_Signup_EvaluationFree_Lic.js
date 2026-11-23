/* eslint-disable no-console */
import { LightningElement } from 'lwc';
/*import getEvalutionProductList from '@salesforce/apex/Sales_CreateLicenseController.getProductList';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createEvalutionLic from '@salesforce/apex/Sales_CreateLicenseProvider.createLic';
import ProductNotSelcted from '@salesforce/label/c.ProductNotSelcted';
import ProductNotSelctedBeforeEditing from '@salesforce/label/c.ProductNotSelctedBeforeEditing';
import FixedNoSeat1 from '@salesforce/label/c.FixedNoSeat1';
import NoProducts from '@salesforce/label/c.NoProducts';
import T_C from '@salesforce/label/c.T_C';
import NoSeats0 from '@salesforce/label/c.NoSeats0';
import NoSeatsBlank from '@salesforce/label/c.Sales_noSeats_Error';
import TermsCondition from '@salesforce/label/c.TermsCondition';
import TermsCondition_Optin from '@salesforce/label/c.TermsCondition_Optin';
import Sales_ofseat from '@salesforce/label/c.Sales_ofseat';
import Sales_Maitenance_Exp from '@salesforce/label/c.Sales_Maitenance_Exp';
import Sales_License_Expiration from '@salesforce/label/c.Sales_License_Expiration';
import Sales_WebDescription from '@salesforce/label/c.Sales_WebDescription';
import Sales_getlegacylic from '@salesforce/label/c.Sales_getlegacylic';
import Sales_Err  from '@salesforce/label/c.Sales_Err';
import Sales_Create_Optional_License from '@salesforce/label/c.Sales_Create_Optional_License';
import { NavigationMixin } from 'lightning/navigation';


/********************************************
Component Name    : Sales_View_Signup_EvaluationFree_Lic
Created Date  : Jul 2021
Function      : US980731

Modification Log :
Developer                 		Date                    Description
ananga.mohan.sen@accenture.com  02/07/2021				 US980731
************************************************************/

/*const columns=[
    //{ label: Sales_Product, fieldName: 'prodName' },
    { label: Sales_WebDescription, fieldName: 'WebDesc',wrapText:true },
    { label: Sales_ofseat, fieldName: 'noSeats', editable: true ,
    cellAttributes: {
		class: 'slds-text-color_success slds-text-title_caps'
	}},
    { label: Sales_Maitenance_Exp, fieldName: 'maintenenceExp' },
    { label: Sales_License_Expiration, fieldName: 'licExp'},
];*/
export default class Sales_View_Signup_EvaluationFree_Lic extends LightningElement {
    /*@track buttonClicked=false;
    result;
    error;
   isload =false;
    dataAvailable;
    termandcondition=false;
    columnsList=columns;
    selectedRows =[];
    changedNoSeats2=[];
    draftValues = [];
    selectedProd = [];
    //T&C logic
    termsAccepted=false;
    termsCondition;
    //used to call generate license component
    licenseRecord=[];
    lic_id;
    licWebFlag;
    licActivationId;
    licensetypevalue;
    primarycontact;

    tooltype;//added for tool type
    navigateToGenerateLic=false;
    //used to call create optional prod
    @api orderItemId=''; //always '' as no order for this scenario
    @api parentLicprodId;
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
        TermsCondition_Optin,
        TermsCondition,
        Sales_WebDescription,
        Sales_ofseat,
        Sales_Maitenance_Exp,
        Sales_License_Expiration,
        Sales_getlegacylic,
        Sales_Err,
        Sales_Create_Optional_License
    };
    TermsCondition_Optin=this.label.TermsCondition_Optin;
    TermsConditionTxt=this.label.TermsCondition;
    ///modal for next component
    bShowModal;
    closeModal(){
        this.bShowModal=false;
    }
    openModal(){
        this.bShowModal=true;
    }
    //modal for genrate license
    showGenrateLicense;
    closeGenerateLicModal(){
        this.showGenrateLicense=false;
    }
    openGenerateLicModal(){
        this.showGenrateLicense=true;
    }
    //optin
    optin=false;
    //use to show/hide optional product screen
    skipOptionalScreen=false;
    licenseType='Evalution';

   
    /********************************************
        Function      : wire method to get list of products
        Modification Log :
        Developer                 		Date                    Description
        ananga.mohan.sen@accenture.com  21/06/2021				 US980732
    ************************************************************/

    /*@wire(getEvalutionProductList,{licenseType:'$licenseType'})
    getEvalutionProductList({ error, data }) {
        if (data) {
            this.result = data;
            console.log('errors>>>'+JSON.stringify(data));
            if(this.result.length>0){
            this.dataAvailable=true;
            this.isload=false;
            }
            else{
                this.isload= true;
                this.dataAvailable=false;
            }
             ///show error in the UI if no records
            this.error = undefined;
        } else if (error) {
            console.log('errors>>>'+JSON.stringify(error));
            this.error = error;
            this.result = undefined;
            this.dataAvailable=false;
            this.isload=true;

        }
    }

  /*  connectedCallback(){
        console.log('connected callback');
        this.dataAvailable=false;
        //this.isload=true;
    }*/
     /********************************************
        Function      : handle the selected row data
        Modification Log :
        Developer                 		Date                    Description
        ananga.mohan.sen@accenture.com  21/06/2021				 US980732
    ************************************************************/
    /*getSelectedRow(event){
        this.selectedRows = event.detail.selectedRows; 
        console.log('selectedRows>>'+JSON.stringify(this.selectedRows));
        for (let i = 0; i < this.selectedRows.length; i++){
            this.selectedProd=[];
            this.termsCondition=this.selectedRows[i].TandC;
            console.log('termsCondition>>>'+this.termsCondition);
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
                optnAvailable:this.selectedRows[i].optnAvailable,
                optin:false,
                isEmployee:false
                
            });
        }
        console.log('selectedProd value after row select>>'+JSON.stringify(this.selectedProd)); 
        this.termandcondition=true;
    }
    /********************************************
        Function      : handle the  get license button click
        Modification Log :
        Developer                 		Date                    Description
        ananga.mohan.sen@accenture.com  21/06/2021				 US980732
    ************************************************************/
    /*handleLicCreate(){
        this.buttonClicked=true;
        console.log('botton'+this.buttonClicked);
        console.log('this.optin>>>>>'+this.optin);
        console.log('selectedProd inside handleLicCreate>>'+JSON.stringify(this.selectedProd)); 
        //optin is true    
        for (let i = 0; i < this.selectedProd.length; i++){
                if(this.optin){
                     this.selectedProd[i].optin=true;
                } 
                if(!this.selectedProd[0].optnAvailable){
                    this.skipOptionalScreen=true;
                }
             console.log('this.selectedProd[0].optin>>>'+this.selectedProd[i].optin);  
             console.log('this.selectedProd[0].optnAvailable>>>'+this.selectedProd[i].optnAvailable);
 
        }         
        
       
        //if bz if optin false then this will also check
        
        console.log('handleLicCreateick  string selectedProd >>'+JSON.stringify(this.selectedProd));

        let reqString=JSON.stringify(this.selectedProd);
        //console.log('handleLicCreateick json object>>'+JSON.parse(JSON.stringify(this.selectedProd)));
        if(this.selectedProd.length===0){
            this.buttonClicked=false;
            console.log('No item has selected');
            this.mode='dismissible';
            this.title=this.label.Sales_Err;
            this.message=this.label.ProductNotSelcted;
            this.variant='error';
            this.showErrorToast();
        }

        if(this.selectedProd[0].noSeats===undefined){
            this.buttonClicked=false;
            console.log('No item has selected');
            this.mode='dismissible';
            this.title=this.label.Sales_Err;
            this.message=this.label.NoSeatsBlank;
            this.variant='error';
            this.showErrorToast();
        }

        else if(!this.termsAccepted){
            this.buttonClicked=false;
            console.log('check box not checked'+this.termsAccepted);
            this.mode='dismissible';
            this.title=this.label.Sales_Err;
            this.message=this.label.T_C;
            this.variant='error';
            this.showErrorToast();
        }
        else{
            this.buttonClicked=true;
            //apex call to create evaluation license
        createEvalutionLic({json:reqString})
        
            .then(result =>{
               this.licenseRecord=result;
               console.log('new license>>'+JSON.stringify(this.licenseRecord));
               this.lic_id=this.licenseRecord.Id;
              // this.licWebFlag=this.licenseRecord.Sales_License_Web_Display_Flag__c;
               this.licActivationId=this.licenseRecord.Sales_License_Activation_Code__c;
               this.primarycontact=this.licenseRecord.Sales_License_Primary_Admin_Contact__c;
               this.tooltype=this.licenseRecord.Sales_License_Product__r.Core_Prod_Tool_Type_Nm__c; //added for tool type
               this.licensetypevalue=this.licenseRecord.Sales_Tool_License_Type__c;
               this.parentLicprodId=this.licenseRecord.Sales_License_Product__c;
                console.log('new eva lic id>>'+this.lic_id+' eva Activateion code>>'+this.licActivationId+
                                '  eva primarycontact>>>'+this.primarycontact+'  eva licensetypevalue>>>'+this.licensetypevalue+'  eva parentLicprodId>>'+this.parentLicprodId);
               if(!this.skipOptionalScreen){
                this.openModal();
               } 
               else
               this.openGenerateLicModal();
               
            })
            .catch(error =>{
                console.log('apex call error'+error);
            })
        }  

    }
     /********************************************
        Function      : handle the  event fire from option product create cmp
        Modification Log :
        Developer                 		Date                    Description
        ananga.mohan.sen@accenture.com  21/06/2021				 US980732
    ************************************************************/
    /*closeOptionModal(event){
        console.log('event handled');
        this.closeModal();
        this.openGenerateLicModal();
    }
   
     /********************************************
        Function      : handle the  edition of seat #
        Modification Log :
        Developer                 		Date                    Description
        ananga.mohan.sen@accenture.com  21/06/2021				 US980732
    ************************************************************/
    /*handleNoSeatsEdit(event){
        console.log('select row val>>'+JSON.stringify(this.selectedRows[0]));
        if(this.selectedRows[0]===undefined){
            //throw error if row not selcted but #seats edited
            this.mode='sticky';
            this.title=this.label.Sales_Err;
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
                        this.selectedProd=[];
                        console.log('inside if, float but seats not 1');
                        this.mode='sticky';
                        this.title=this.label.Sales_Err;
                        //this.message='# of seats should be 1 if License type is Fixed';
                        this.message=this.label.FixedNoSeat1;
                        //FixedNoSeat1
                        this.variant='error'
                        this.showErrorToast();
                        break;
                     }
                      //error for #seat equals 0 
                     console.log('changed seats before error>>>'+this.changedNoSeats2[j].noSeats);
                    if(this.changedNoSeats2[j].noSeats==='0'){
                        this.selectedProd=[];
                        console.log('#seats is 0');
                        this.mode='sticky';
                        this.title=this.label.Sales_Err;
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
                    //displayEditIcon:selectedRows[i].displayEditIcon,
                    prodExtId:this.selectedRows[i].prodExtId,
                    prodId:this.selectedRows[i].prodId,
                    prodName:this.selectedRows[i].prodName,
                    maxRehost:this.selectedRows[i].maxRehost,
                    prodExtTempLicAllowed:this.selectedRows[i].prodExtTempLicAllowed,
                    optnAvailable:this.selectedRows[i].optnAvailable,
                    optin:false,
                    isEmployee:false
                    
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
        ananga.mohan.sen@accenture.com  21/06/2021				 US980732
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
        ananga.mohan.sen@accenture.com  21/06/2021				 US980732
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
    /********************************************
        Function      : T&C
        Modification Log :
        Developer                 		Date                    Description
        ananga.mohan.sen@accenture.com  7/07/2021				 US980731
    *******************************************************
    handleT_C(){
        this.openGenerateLicModal();
    }
    /********************************************
        Function      : Optin/out
        Modification Log :
        Developer                 		Date                    Description
        ananga.mohan.sen@accenture.com  7/07/2021				 US980731
    ************************************************************/
    /*handleOptin(event){
        if (event.target.checked)
        {
            this.optin=true;
        }
        else
        this.optin=false;

    }*/
   
}