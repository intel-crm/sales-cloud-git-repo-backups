import { LightningElement,api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import validateComputer from '@salesforce/apex/Sales_LicenseRecordPageComponentsUtility.validateComputerId';
import generateLicenseFile from '@salesforce/apex/Sales_LicenseGenIntegration_Utility.returnHostIdDetail';
import invalidPrimaryComputerId from '@salesforce/label/c.Sales_InvalidCompId_Msg';     
import successLicenseFileMsg from '@salesforce/label/c.Sales_licensefile_SuccessMsg';  
import licensefilefailure from '@salesforce/label/c.Sales_LicenseFileFailure_Msg';    
import legacylicenseheading from '@salesforce/label/c.Sales_LegacyLicenseHeading';    
import computerIdURL from '@salesforce/label/c.Sales_PrimaryId_URl';    
import legacyLicenseHeader from '@salesforce/label/c.Sales_legacyHeader'; 
import legacyComputerId from '@salesforce/label/c.Sales_LegacyComputerIdCheck'; 
import Sales_Legacylic from '@salesforce/label/c.Sales_Legacylic';  
import Sales_legacyurl from '@salesforce/label/c.Sales_legacyurl'; 
import Sales_queslegacy from '@salesforce/label/c.Sales_queslegacy'; 
import Sales_namelegacy from '@salesforce/label/c.Sales_namelegacy'; 
import Sales_getlegacylic from '@salesforce/label/c.Sales_getlegacylic';
import Sales_Sorrymsg from '@salesforce/label/c.Sales_Sorrymsg';
import Sales_ermsg from '@salesforce/label/c.Sales_ermsg';
import Sales_Failuremsg from '@salesforce/label/c.Sales_Failuremsg';
//import Sales_getlegacylic from '@salesforce/label/c.Sales_getlegacylic';



 
             
export default class Sales_GenerateLegacyLicense extends LightningElement {
@api computerInput ;
@api hostId;
//custom labels 
label = {
    invalidPrimaryComputerId,
    successLicenseFileMsg,
    licensefilefailure,
    legacylicenseheading,
    computerIdURL,
    legacyLicenseHeader,
    legacyComputerId,
    Sales_Legacylic,
    Sales_legacyurl,
    Sales_queslegacy,
    Sales_getlegacylic,
    Sales_namelegacy,
    Sales_Sorrymsg,
    Sales_ermsg,
    Sales_Failuremsg
    
};

handleInputFieldChange(event){
    this.computerInput = event.target.value;//storing the computer id user has entered 
}
//method to validated maintenance duration on the license associated to the host
handleComputer(event){
    if(this.computerInput!=null && this.computerInput!=undefined && this.computerInput!=''){
        validateComputer({computerId: this.computerInput}) //method to validate the host and maintenance date on the license
                .then(result => {
                    if(result.isvalidHost){
                        console.log('Calling gethostId ');
                      
												this.hostId=result.hostId;
												 this.generateFile();
                        console.log('Call to generateFile ');
                        
                         
                    }else{
                    const evt = new ShowToastEvent({
                        title: this.label.Sales_Sorrymsg+' '+this.computerInput +' '+this.label.invalidPrimaryComputerId,
                        message: '',
                        variant: 'error',
                        mode: 'sticky'
                    });
                    this.dispatchEvent(evt);    
                }
            })
    }else{
        //show error message
        const evt = new ShowToastEvent({
            title: this.label.legacyComputerId,
            message: '',
            variant: 'error',
            mode: 'sticky'
        });
        this.dispatchEvent(evt); 
    }
}

//method to generate the license file
generateFile(){
    if(this.hostId!=undefined && this.hostId!=null && this.hostId!=''){
        generateLicenseFile({ input: this.hostId, inputType: 'HostId',eventType: '' })
        .then((result) => {
            if (result) {//error message if any exception recieved in generating the file
                this.fireToastEvent(this.label.Sales_Failuremsg, this.label.licensefilefailure, 'error', 'dismissable');
                this.reloadPage();
            }
            else {//displaying success message response
                this.fireToastEvent(this.label.successLicenseFileMsg,'' ,'success', 'dismissable');
                this.reloadPage();
            }
        })
        .catch((error) => {
            this.fireToastEvent(this.label.Sales_ermsg, error.body.message, 'error', 'sticky');
        });
    }    
}

//toast message method 
fireToastEvent(title, message, variant, mode) {
    const event = new ShowToastEvent({
        title: title,
        message: message,
        variant: variant,
        mode: mode
    });
    this.dispatchEvent(event);
}
//method to reload the page
reloadPage() {
    setTimeout(function () {
        location.reload(true);
    }, 2000);
}
}