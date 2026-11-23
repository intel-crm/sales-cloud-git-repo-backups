import { LightningElement } from 'lwc';
import getQueryResult from '@salesforce/apex/Core_IPS_NewMapHomePageController.getQueryResult';

export default class Design extends LightningElement {
    productRecords;
    getProductData() {
        let searchQueryStr = 'select id, Name,Core_Product_Organization__c,core_supported_product__c,Core_IPS_Project__c,Core_Support_Org_Name__c from asset limit 5';
        getQueryResult({
            queryString: searchQueryStr
        })

        .then(data =>{
            if(data){

                this.productRecords = data;

                let options= [];

                data.forEach(eachRecord => {

                    console.log('each record==>'+eachRecord);

                    options.push({ value: eachRecord.Id, label: eachRecord.Name });

                }); 

                this.productOptions = options;
            }

        })

        .catch(error =>{

            console.log('prod error===>'+JSON.stringify(error));

        })

    }
    
    connectedCallback() {

        this.getProductData();

    }
    
    listOptions = [
        { value: 'Intel Xeon Platinum 8362', label: 'Intel Xeon Platinum 8362' },
        { value: 'Intel Xeon Platinum 8380', label: 'Intel Xeon Platinum 8380' },
        { value: 'Intel Xeon Platinum 8351', label: 'Intel Xeon Platinum 8351' },
        { value: 'Intel Xeon Platinum 8368', label: 'Intel Xeon Platinum 8368' },
        { value: 'Intel Xeon Platinum 8384', label: 'Intel Xeon Platinum 8384' },        
    ];

    // defaultOptions = ['Intel Xeon Platinum 8362'];
    // console.log(this.listOptions[0]);
    
}