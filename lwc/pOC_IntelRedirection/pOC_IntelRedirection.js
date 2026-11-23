import { LightningElement, track } from 'lwc';
import getBaseUrlForLaunguageCode from '@salesforce/apex/IPA_MarqueeMarketplaceController.getBaseUrlForLaunguageCode';
//import { NavigationMixin } from 'lightning/navigation';

export default class POC_IntelRedirection extends LightningElement{
    
    @track baseUrlRecord;
    @track error;
    searchQuery = '';
    baseUrl = 'https://www.intel.com/content/www/us/en/search.html#q=';
    trailText = '&t=Partners';
    updateValue(event){
        this.searchQuery = event.detail.value;
    }
    
    inputUrl = '';
    // Navigation to Intel Home page 
    navigateToIntel(event){
        var keypressed = (event.which) ? event.which : event.keyCode;
        if (this.searchQuery !== '' && keypressed == 13 ) { //Redirecting only if any value there in search box and enter key pressed
            var intelLocale = this.getLanguageCookie('PrefLangIETF'); //FInal Name to be shifted to custom label
            //this.inputUrl = this.baseUrl+this.searchQuery+this.trailText; //Final Component will fetch these from metadata
            console.log('languageCode-->'+intelLocale);
            if(intelLocale){
               getBaseUrlForLaunguageCode({ languageCode: intelLocale })
               .then(result => {
                    this.baseUrlRecord = JSON.parse(result);
                    this.inputUrl = this.baseUrlRecord.BaseURL__c+this.searchQuery+this.baseUrlRecord.Tab__c;
                    //window.location.href = this.inputUrl;
               })
               .catch(error => {
                   this.error = error;
               });
            }/*else{
                set the default UserLocale
            }*/
            
            //window.location.href = this.inputUrl; 
        }
    }  

    getLanguageCookie(intelLanguage){
        console.log('param-->'+intelLanguage);
        var language = intelLanguage + "=";
        //document.cookie = "PrefLangIETF=En_us";
        console.log('documentCookie-->'+document.cookie);
        var decodedCookie = decodeURIComponent(document.cookie);
        console.log('decodedCookie-->'+decodedCookie);
        var cookies = decodedCookie.split(';');
        for(var i = 0; i <cookies.length; i++) {
            var c = cookies[i];
            console.log('cookie c-->'+c);
            while (c.charAt(0) == ' ') {
            c = c.substring(1);
            }
            console.log('Index-->'+c.indexOf(language));
            if (c.indexOf(language) == 0) {
            return c.substring(language.length, c.length);
            }
        }
        return "";
    } 
}