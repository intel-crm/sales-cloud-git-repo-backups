import LightningModal from 'lightning/modal';
//import getTags from '@salesforce/apex/Core_CRM_Utility.getTags';
//import getTagCount from '@salesforce/apex/Core_CRM_Utility.getTagCount';
import getTagsWithCount from '@salesforce/apex/Core_CRM_Utility.getTagsWithCount';
export default class Core_TagsPopup extends LightningModal {
    showTable = false;
    tagDetails = [];
    filteredTagDetails = [];
    isLoading = false;

    searchKey ='';
    delayTimeout;

    pageSize = 5;
    offset = 0;
    totalRecords = 0;

    columns = [
        { label: 'Tag Name', fieldName: 'Name', wrapText: true },
        { label: 'Tag Definition', fieldName: 'Core_Tag_Definition__c', wrapText: true },
        { label: 'Business Purpose', fieldName: 'Core_Business_Purpose__c', wrapText: true}, 
        { label: 'Business Owner', fieldName: 'Core_Business_Owner__r.Name', wrapText: true }
    ];

    async connectedCallback(){
       await this.loadAll();
    }

    async loadAll(){
        this.isLoading = true;
        try{
            this.offset = 0;
            this.searchKey = '';
            //await this.loadCountt();
            await this.loadData(); 
        }
        catch(e){
            console.error(e);
        }
        finally{
            this.isLoading = false;
        }
    }
    /*
    loadData(){
            return getTags({ limitSize: this.pageSize, offsetSize: this.offset, searchKey: this.searchKey })
                .then(result => {
                    this.tagDetails = result.map(record => ({
                        ...record,
                        'Core_Business_Owner__r.Name': record.Core_Business_Owner__r ? record.Core_Business_Owner__r.Name : ''
                    }));
                })
                .catch(error => {
                    console.error(error);
                    throw error;
                });
    }
    loadCount(){
        return getTagCount({searchKey: this.searchKey })
                .then(result => {
                    this.totalRecords = result;
                })
                .catch(error => {
                    console.error(error);
                    throw error;
                });
    }*/
    loadData(){
            return getTagsWithCount({ limitSize: this.pageSize, offsetSize: this.offset, searchKey: this.searchKey })
                .then(result => {
                    this.tagDetails = result.tags.map(record => ({
                        ...record,
                        'Core_Business_Owner__r.Name': record.Core_Business_Owner__r ? record.Core_Business_Owner__r.Name : ''
                    }));
                    this.totalRecords = result.totalCount;
                })
                .catch(error => {
                    console.error(error);
                    throw error;
                });
                
    }/*
    loadCountt(){
        return getTagsWithCount({ limitSize: this.pageSize, offsetSize: this.offset, searchKey: this.searchKey })
                .then(result => {
                    this.totalRecords = result.totalCount;
                })
                .catch(error => {
                    console.error(error);
                    throw error;
                });
    }*/
    handleSearch(event){
        const value = event.target.value;
        //this.searchKey = event.target.value.toLowerCase();
        window.clearTimeout(this.delayTimeout);
        this.delayTimeout = setTimeout(async ()=> {
            this.searchKey = value;
            //console.log('value in search', value);
            this.isLoading = true;
            this.offset = 0;

            try{
                //await this.loadCountt();
                await this.loadData();
            }
            catch(e){
                console.error(e);
            }
            finally{
                this.isLoading = false;
            }
        }, 800);
        /*if(!this.searchKey){
            this.filteredTagDetails= [...this.tagDetails];
            return;
        }

        this.filteredTagDetails = this.tagDetails.filter( record => {
            return(
                (record.Name && record.Name.toLowerCase().includes(this.searchKey))
            );
        });*/
        //this.applySearch();
    }
    applySearch(){
        if(!this.searchKey){
            this.filteredTagDetails= [...this.tagDetails];
            return;
        }

        this.filteredTagDetails = this.tagDetails.filter( record => {
            return(
                (record.Name && record.Name.toLowerCase().includes(this.searchKey))
            );
        });
    }
    async handleRefresh(){
        this.searchKey='';
        this.isLoading = true;
        try {
            await this.loadAll();
        }
        catch(e){
            console.error(e);
        }
        finally{
            this.isLoading = false;
        }
    }
    async handleNext(){
        this.offset += this.pageSize;
        this.isLoading = true;
        try{
            await this.loadData();
        }
        catch(e){
            console.error(e);
        }
        finally{
            this.isLoading = false;
        }
        
    }
    async handleBack(){
        this.offset -= this.pageSize;
        this.isLoading = true;
        try{
            await this.loadData();
        }
        catch(e){
            console.error(e);
        }
        finally{
            this.isLoading = false;
        }
    }
    get disableBack(){
        return (this.offset === 0);
    }
    get disableNext(){
        return (this.offset + this.pageSize >= this.totalRecords);
    }
    get hasData(){
        return this.tagDetails && this.tagDetails.length > 0;
        //return this.totalRecords > 0;
    }
    get showNoResults(){
        return !this.isLoading && this.totalRecords === 0;
    }
    get isSearchActive(){
        return this.searchKey && this.searchKey.length > 0;
    }
}