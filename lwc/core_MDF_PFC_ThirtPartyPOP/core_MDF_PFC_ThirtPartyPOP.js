import { LightningElement, track, api  } from 'lwc';
import isValidThirdPartyPOPClaim from "@salesforce/apex/Core_MDF_PFC_ThirdPartyPOP.isValidThirdPartyPOPClaim";
import isClaimFlagedForThirdPartyPOP from "@salesforce/apex/Core_MDF_PFC_ThirdPartyPOP.isClaimFlagedForThirdPartyPOP"; // Record Page to get Saved Flag value
import Core_MDF_ApplicationErrorMessage from "@salesforce/label/c.Core_MDF_ApplicationErrorMessage";
import Core_MDF_ThirdPartyPOPMessage from "@salesforce/label/c.Core_MDF_ThirdPartyPOPMessage";


export default class Core_MDF_PFC_ThirtPartyPOP extends LightningElement {
    @api recordId;
    @track message;
    @api claimObj;
    ruleId = '';
    isThirdPartyPOP = '';
    haserror = false;
    @track displayPOPMessage = false; // Based on rule engine update displayPOPMessage value
    ruleId;
    isThirstPartyPOP;
        
    label = {
        Core_MDF_ApplicationErrorMessage ,
        Core_MDF_ThirdPartyPOPMessage
    };

    connectedCallback() { 
        console.log('Core_MDF_PFC_ThirtPartyPOP connectedCallback called');
        console.log('recordId'+this.recordId);
        if(this.recordId!=null){ // Detail page // check for undefine
            console.log('recordId'+this.recordId);
            isClaimFlagedForThirdPartyPOP({claimRecordId: this.recordId})
            .then(data =>{
                if (data) {
                    this.displayPOPMessage = data.isThirdPartyPOP;
                    console.log(' if block : this.displayPOPMessage'+this.displayPOPMessage);
                    const value = data; 
                        const valueChangeEvent = new CustomEvent('isThirdPartyPOP', { 
                        detail: { value }
                    });
                    this.displayThirdPartyPOPMessage();
                    this.dispatchEvent(valueChangeEvent); 

                }
                //this.displayThirdPartyPOPMessage();
                
            })


        }else{
            console.log('third party else');
            isValidThirdPartyPOPClaim({ pfc: this.claimObj }) 
            .then(data => {
                if (data) {
                    console.log('data::'+data);
                    this.ruleId = data.ruleId;   
                    this.isThirdPartyPOP = data.isThirdPartyPOP; 
                    console.log('ruleId'+this.ruleId+'isThirdPartyPOP'+this.isThirdPartyPOP);                   
                    if(this.isThirdPartyPOP){
                        this.displayPOPMessage = this.isThirdPartyPOP;  
                    }   
                    const value = data; 
                        const valueChangeEvent = new CustomEvent('isThirdPartyPOP', { 
                        detail: { value }
                    });
                    this.displayThirdPartyPOPMessage();
                    this.dispatchEvent(valueChangeEvent);     
                    
                }
            }).catch(error=>{
                if (error) {
                    this.haserror = true;
                    console.log('Error in loading 3rd Party POP message. Error : ',this.error);
                }
            })

        }
                    

    }

    displayThirdPartyPOPMessage() { 
        console.log('inside isThirdPartyPOP'+this.displayPOPMessage);
        if(this.displayPOPMessage){
        this.message = Core_MDF_ThirdPartyPOPMessage;
        }
    }

    
}