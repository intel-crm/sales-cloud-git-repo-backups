import { LightningElement, track,api} from 'lwc';
import getIdentityDetails from '@salesforce/apex/Core_A_E_Get_Identity_Details.getIdentityDetails';
export default class coreAEGetIdentityDetails extends LightningElement {
    @api Email ;
    @track SName = '';
    @track searchString;
    @track PersonID = '';
    @track ERPMStatus = '';
    @track ERPMMessage = '';
    @track EnterpriseID = '';
    @track AGSStatus = '';
    @track AGSMessage = '';
    @track entDetails;

    @track ERPMName = '';
    @api ERPMEmail = '';
    @track eRPMPersonID = '';
    @track eRPMEnterpriseID = '';
    @track eRPMIdentityStatus = '';

    @track AGSEnterpriseID = '';
    @track Roles = '';
    
    @track B2BDisplayName = '';
    @track B2BGivenName = '';
    @track B2BSurname = '';
    @api B2BEmail = '';
    @track B2BEnterpriseID = '';
    @track B2Bid = '';
    @api B2BotherEmails = '';
    @track B2BGroups = '';

    @track B2CDisplayName = '';
    @track B2CGivenName = '';
    @track B2CSurname = '';
    @api B2CEmail = '';
    @track B2CEnterpriseID = '';
    @track B2Cid = '';
    @api B2CotherEmails = '';
    @track B2CGroups = '';
    

    @track showtable =false;

    handleEmailChange(event) {
        this.searchString = event.detail.value;
        console.log('Email'+this.searchString)
    }


    searchIdentity() {
        getIdentityDetails({ searchString: this.searchString })
            .then(result => {
                this.parseResult =JSON.parse(result)
                console.log('Result' +  this.parseResult );
                this.actualParseDetails = JSON.stringify( this.parseResult)
                console.log ('Actual result '+ JSON.stringify( this.parseResult));
                this.Email = this.parseResult.sfContactDetails.Email;
                this.SName = this.parseResult.sfContactDetails.Name;
                this.PersonID = this.parseResult.sfContactDetails.Core_eRPM_Person_Id__c;
                this.ERPMStatus = this.parseResult.sfContactDetails.Core_ERPM_Integration_Status__c;
                this.ERPMMessage = this.parseResult.sfContactDetails.Core_ERPM_Integration_Message__c;
                this.EnterpriseID = this.parseResult.sfContactDetails.Core_Enterprise_Id__c;
                this.AGSStatus = this.parseResult.sfContactDetails.Core_AGS_Integration_Status__c;
                this.AGSMessage = this.parseResult.sfContactDetails.Core_AGS_Integration_Message__c; 
                this.entDetails = this.parseResult.sfContactDetails.Contact_Entitlements__r.records;


                //ERPM Profile details
                this.ERPMName = this.parseResult.sfContactDetails.Name;
                this.ERPMEmail = this.parseResult.sfContactDetails.Email;
                this.eRPMPersonID = this.parseResult.sfContactDetails.Core_eRPM_Person_Id__c;
                this.eRPMEnterpriseID = this.parseResult.sfContactDetails.Core_Enterprise_Id__c;
                this.eRPMIdentityStatus = this.parseResult.sfContactDetails.Core_Identity_Status__c;

                //AGS
                this.AGSEnterpriseID = this.parseResult.agsRoleDetails.enterpriseId;
                this.Roles = this.parseResult.agsRoleDetails.roles;

                //  Azure B2B
                this.B2BDisplayName = this.parseResult.azureB2BIdentityDetails.displayName;
                this.B2BGivenName = this.parseResult.azureB2BIdentityDetails.givenName;
                this.B2BSurname = this.parseResult.azureB2BIdentityDetails.surname;
                this.B2BEmail = this.parseResult.azureB2BIdentityDetails.mail;
                this.B2BEnterpriseID = this.parseResult.azureB2BIdentityDetails.enterpriseId;
                this.B2Bid = this.parseResult.azureB2BIdentityDetails.id;
                this.B2BotherEmails = this.parseResult.azureB2BIdentityDetails.otherMails;
                this.B2BGroups = this.parseResult.azureB2BMembershipDetails.displayName;

                //  Azure B2C
                this.B2CDisplayName = this.parseResult.azureB2CIdentityDetails.displayName;
                this.B2CGivenName = this.parseResult.azureB2CIdentityDetails.givenName;
                this.B2CSurname = this.parseResult.azureB2CIdentityDetails.surname;
                this.B2CEmail = this.parseResult.azureB2CIdentityDetails.mail;
                this.B2CEnterpriseID = this.parseResult.azureB2CIdentityDetails.enterpriseId;
                this.B2Cid = this.parseResult.azureB2CIdentityDetails.id;
                this.B2CotherEmails = this.parseResult.azureB2CIdentityDetails.otherMails;
                this.B2CGroups = this.parseResult.azureB2CIdentityDetails.azureB2CMembershipDetails	;

                this.showtable = true;
            })
            .catch(error => {
                console.error('Error fetching identity', error);
                console.log(JSON.stringify(error))
            });
    }
}