import { LightningElement, api, track } from 'lwc';
import Core_IPS_SBS_Iframe_Url from '@salesforce/label/c.Core_IPS_SBS_Iframe_Url';

export default class Core_IPS_SearchBeforeSubmit_iFrame_LWC extends LightningElement {
    productSearchIframeUrl= Core_IPS_SBS_Iframe_Url;
    @api casedata;
    @track url;
    @track finalUrl;
    // subject='iframe'

    connectedCallback(){
        const caseinfo = JSON.parse(this.casedata);
        // const sub = caseinfo.Subject.replace(/' '/g, '%20');


        // this.finalUrl = this.productSearchIframeUrl.concat('sub='+sub);

        // const sub = caseinfo.Subject.replaceAll(' '+ '%20');
        // const prodName = caseinfo.ProductName.replaceAll(' '+'%20');
        // const cat = caseinfo.CategoryName.replaceAll(' '+ '%20');
        // const sCat = caseinfo.SubCategoryName.replaceAll(' '+'%20');

        let url = this.productSearchIframeUrl.concat('sub='+caseinfo.Subject+'&lang=en_us&prod='+caseinfo.ProductName+'&cat='+caseinfo.CategoryName+'&area='+caseinfo.SubCategoryName);
        // let modifiedUrl = url.replaceAll('\\s'+'%20');
        let encURI = encodeURI(url);
        this.finalUrl = encURI;
        // console.log('iframe url>>>>>>>>'+this.url);
        console.log('finalurl>>>>>>>'+ this.finalUrl);
    }
}