import { LightningElement,track } from 'lwc';
import getTags from '@salesforce/apex/Core_CRM_Utility.getTags';
import getTagCount from '@salesforce/apex/Core_CRM_Utility.getTagCount';
export default class Core_UniTagDetails extends LightningElement {

    @track showTable = false;
    @track tagDetails = [];
    @track isLoading = false;

    pageSize = 5;
    offset = 0;
    totalRecords = 0;

    columns = [
        { label: 'Tag Name', fieldName: 'Name', wrapText: true },
        { label: 'Definition', fieldName: 'Core_Tag_Definition__c', wrapText: true },
        { label: 'Business Purpose', fieldName: 'Core_Business_Purpose__c', wrapText: true}, 
        { label: 'Business Owner', fieldName: 'Core_Business_Owner__r.Name', wrapText: true }
    ];

    handleClick(){
        this.showTable = true;
        this.loadData();
        this.loadCount();
    }
    loadData(){
            return getTags({ limitSize: this.pageSize, offsetSize: this.offset })
                .then(result => {
                    this.tagDetails = result.map(record => {
                        return {
                            ...record,
                            'Core_Business_Owner__r.Name': record.Core_Business_Owner__r ? record.Core_Business_Owner__r.Name : ''
                        };
                    });
                })
                .catch(error => {
                    console.error(error);
                    throw error;
                });
    }
    loadCount(){
        return getTagCount()
                .then(result => {
                    this.totalRecords = result;
                })
                .catch(error => {
                    console.error(error);
                    throw error;
                });
    }
    handleNext(){
        this.offset += this.pageSize;
        this.loadData();
    }
    handleBack(){
        this.offset -= this.pageSize;
        this.loadData();
    }
    toggleTable(){
        this.showTable = !this.showTable;
        if(this.showTable && this.tagDetails.length === 0){
            this.loadData();
            this.loadCount();
        }

    }
    async handleRefresh(){
        this.isLoading = true;
        
        try {
            this.offset = 0;
            this.tagDetails = [];

            await this.loadCount();
            await this.loadData();
        } catch(error){
            console.error(error);
        } finally {
            console.log('inside finally 78');
            this.isLoading = false;
        }
        

        /*this.loadCount()
        .then(() => {return this.loadData();})
        .finally(() => { 
            this.isLoading = false;
         });*/
    }    
    get disableBack(){
        return this.offset === 0;
    }
    get disableNext(){
        return this.offset + this.pageSize >= this.totalRecords;
    }
    get toggleLabel(){
        return this.showTable ? 'Hide Tags' : 'Show Tags';
    }

}