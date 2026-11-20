import { LightningElement, api, track } from 'lwc';

export default class UcdNonLatinLanguage extends LightningElement {
    /* variables for methods*/
    @track isModalOpen = true;
    @track isnamespecial = false;
    @track isModalOpenNew = '';
    @track  isadd1special = false;
    @track  isadd2special = false;
    @track  iscityspecial = false;
    @track nospecialcharNew = false;
    @api nonLatinArray;
    @track payloadNew= {};
    /* End of variables */
    //ConncetedCallback to get updated values */
     connectedCallback(){
        console.log('YESSSSSSSS'+JSON.stringify(this.nonLatinArray));
         if(this.nonLatinArray.accname != '' && this.nonLatinArray.accname != undefined){
            this.isnamespecial = true;
         } 
         if(this.nonLatinArray.addressline1 != '' && this.nonLatinArray.addressline1 != undefined){
            this.isadd1special = true;
         }
         if(this.nonLatinArray.addressline2 != '' && this.nonLatinArray.addressline2 != undefined){
            this.isadd2special = true;
         }
         if(this.nonLatinArray.city != '' && this.nonLatinArray.city != undefined){
            this.iscityspecial = true;
         }
     }
     /* below method to show / hide input box */
     inputChangeHandler(event) {
        if (event.target.name == 'tName') {
            this.payloadNew.tname = event.target.value;
        }
        if (event.target.name == 'taddressline1') {
            this.payloadNew.taddressline1 = event.target.value;
        }
        if (event.target.name == 'taddressline2') {
            this.payloadNew.taddressline2 = event.target.value;
        }
        if (event.target.name == 'tcity') {
            this.payloadNew.tcity = event.target.value;
        } 
    }
    /* close model to close window on click of close icon */
    closeModal() {
        this.isModalOpenNew = false;
        this.nonLatinArray = [];
        const acctLanguageCheckClose = new CustomEvent("acctlanguagecheckclose", { detail: this.isModalOpenNew });
        this.dispatchEvent(acctLanguageCheckClose);
    }
    /*skip model to navigate duplicate scrren with out any new values */
    skipModal(){
        this.payloadNew.tname ='';
        this.payloadNew.taddressline1 = '';
        this.payloadNew.taddressline2 = '';
        this.payloadNew.tcity = '';
        //okModal();
        //this.isModalOpenNew = false;
        this.isModalOpen = false;
        this.Navigatetodupscreen();
     }
     /*ok model to navigate duplicate scrren with new values */
    okModal(){
        this.isModalOpen = false;
        this.isnamespecial = false;
        this.isadd1special = false;
        this.isadd2special = false;
        this.iscityspecial = false;
        this.Navigatetodupscreen();
    }
    /* navigation method to go to duplicate scrren on click of ok and skip modal */
    Navigatetodupscreen(){
        const acctLanguageCheck = new CustomEvent("acctlanguagecheck", { detail: this.payloadNew });
        this.dispatchEvent(acctLanguageCheck);
}
}