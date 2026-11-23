import { LightningElement, track } from 'lwc';
import findWherethisisUsed from '@salesforce/apex/Tooling_CustomLabelCntrl.findWhereThisIsUsed';

export default class CheckCustomLabelUsage extends LightningElement {
    @track labelDeveloperName;
    @track data=[];
    @track columns=[];
    @track data = [];
    @track colNames= [];

    get getTotal() {
        return this.data.length;
    }
    

    handleInputChange(evt){
        this.labelDeveloperName = evt.target.value;
    }

    handleSearch(){
        this.data = [];
        findWherethisisUsed({labelDeveloperName : this.labelDeveloperName}).then(result =>{
            console.log('result -->', result);
            result.map(item => {

                Object.keys(item).forEach(key => {
                    
                    if(!this.colNames.includes(key)){
                        this.colNames.push(key);
                    }
                    
                  });
                  item.url = '/'+item.MetadataComponentId;
                  item.itemurl = '/'+item.RefMetadataComponentId;
                this.data.push(item);

                const col = [];
                this.colNames.map(item=>{
                    if(item == 'MetadataComponentName'){
                        col.push({"fieldName": "url", "label": item, "typeAttributes": {"label": {"fieldName": item}, "target": "_blank"}, "type": "url", "cellAttributes": { "wrapText":"true" }})
                        //col.push({'label':item, 'fieldName':'url','type':'url',typeAttributes: { label:item, fieldName: item } });
                    }
                    else if(item == 'RefMetadataComponentName'){
                        col.push({"fieldName": "itemurl", "label": item, "typeAttributes": {"label": {"fieldName": item}, "target": "_blank"}, "type": "url", "cellAttributes": { "wrapText":"true" }})
                    }else if(item !== 'MetadataComponentId' || item !=='RefMetadataComponentId'){
                        col.push({'label':item, 'fieldName':item,'type':'text'});
                    }
                    
                })
                this.columns = col;
            })
        })
        .catch(error=>{
            console.log('CheckCustomLabelUsage.handleSearch.findWherethisisUsed Error ==>', error);
        })
    }
}