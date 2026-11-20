import { LightningElement,track, wire, api } from 'lwc';
//import Core_GABanner from '@salesforce/label/c.Core_GABanner';
import getBannerDetails from '@salesforce/apex/Core_GrantAccessBanner.getBannerDetails';
import checkContactGec from '@salesforce/apex/Core_GrantAccessBanner.checkContactGec';


export default class Core_GrantAccessBanner extends LightningElement {
    @api recordId;
    // label = {Core_GABanner};
    // bannerDetails;
    isVisible = true;
    isGec=true;
    @track data;
    // constructor(){
    //     super();
    //     this.bannerDetails = this.label.Core_GABanner.split("\n");
    //     console.log(this.label.Core_GABanner);
    // }

    connectedCallback(){
    checkContactGec({recordId:this.recordId})
    .then(result => {
        this.data=result;
          if(this.data==false)
          { 
                this.isGec=true;
                console.log('gec-->'+isGec);
          }
          else{
            this.isGec=false;
            console.log('gec-->'+isGec);
          }

    
    })
    .catch(error => {

        console.log('-------error-------------'+error);

        console.log(error);

    });
}
    
    @wire(getBannerDetails ) wiredDetails;




    
    handleCancel(){

        this.isVisible = false;
}
}