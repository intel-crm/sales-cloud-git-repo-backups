import { LightningElement,api,wire } from 'lwc';
import {refreshApex} from '@salesforce/apex';
import getSupportedProducts from '@salesforce/apex/Core_IPS_PARCreation_Controller_Lex.getSupportedProducts';



export default class DatatableForParLex extends LightningElement {

    @api srchText;
    @api recordId;
    data=[];
    draftValues=[];
    refreshData =[];
    slicedSpList =[];
    accountsData =[];
    columns=[{label: 'Supported Product Name', fieldName: 'name',type: "text",editable:true},
        {label: 'Code Name', fieldName: 'CodeName',type: "text"},
        {label: 'Product Name EPM ID', fieldName: 'EPMID',type: "text"},
        { label: 'Product Focus Area', fieldName: 'ProdArea',type: "picklistEditTemplate",editable:false, typeAttributes:{
            options: {fieldName:'ProdOptions'},
            value :{fieldName:'ProdArea'},
            context:{fieldName:'Id'},
            placeholder :'Select Product Focus Area',
            
        }}
    ];
    
connectedCallback(){
    console.log('In child search text=',this.srchText);
}

    
    
            @wire(getSupportedProducts,{searchText: '$srchText'})
            getData(data){
                console.log('text',this.srchText);
                this.refreshData = data;
                //this.sendData();
                if(data!=null){
                    console.log('data in child',data);
                    //this.data = data;
                    console.log('Data length=',this.refreshData.length);
                    console.log('Refreshed Date',this.refreshData[0]);
                    data.forEach(element => {
                        let options=[];
                       /* for(let i=0;i<element.prodOrgs.length;i++){
                            let obj1 ={
                                'label': element.prodOrgs[i].value,
                                'value': element.prodOrgs[i].value,
                                'Id': element.prod.Id
                            };
                            options.push(obj1);
                        }*/
                        let obj={
                            'name': element.prod.Name,
                            'CodeName': element.prod.Core_Code_Name__c,
                            'EPMID': element.prod.Core_Product_Name_EPM_ID__c,
                            'ProdArea': element.prodOrgs[0].value,
                            'ProdOptions' : options,
                            'Id' : element.prod.Id
                        };
                        //this.accountsData = [];
                        //this.slicedSpList =[];
                        this.accountsData = [...this.accountsData,obj];
                        if(this.accountsData.length <= 5) {
                            console.log('inside if to handle pagination');
                            this.slicedSpList = this.accountsData;
                         }
                         else {
                            this.slicedSpList = this.accountsData.slice(0, 5);
                         }
                    });
                    console.log('Data',this.accountsData);
                    /*for(let i=0;i<data.length;i++){
                        console.log('SPNAme',data[i].prod.Name);
                        let options=[];
                        for(let j=0;j<data[i].prodOrgs.length;j++){
                            let obj1 ={
                                'label': data[i].prodOrgs[j].value,
                                'value': data[i].prodOrgs[j].value,
                                'Id':data[i].prod.Id
                            };
                            options.push(obj1);
                        }
                        console.log('Options=',options);
                        console.log(JSON.stringify(this.data[i].prodOrgs));
                        //options.push(data[i].prodOrgs);
                        let obj={
                            'name': data[i].prod.Name,
                            'CodeName': data[i].prod.Core_Code_Name__c,
                            'EPMID': data[i].prod.Core_Product_Name_EPM_ID__c,
                            'ProdArea': data[i].prodOrgs[0].value,
                            'ProdOptions' : options,
                            'Id' : data[i].prod.Id
                        };
                        //this.accountsData = [];
                        //this.slicedSpList =[];
                        this.accountsData = [...this.accountsData,obj];
                        if(this.accountsData.length <= 5) {
                            console.log('inside if to handle pagination');
                            this.slicedSpList = this.accountsData;
                         }
                         else {
                            this.slicedSpList = this.accountsData.slice(0, 5);
                         }
                    }*/
                    this.lastSavedData = this.accountsData;
                    
                    console.log('data',JSON.stringify(this.accountsData));
                }
                
               // return refreshApex(this.accountsData);
            }
            sendData(){
                console.log('data',this.refreshData);
                this.dispatchEvent(new CustomEvent('sendDataToParent', {
                    composed: true,
                    bubbles: true,
                    cancelable: true,
                    detail: {
                        data: this.refreshData
                    }
                }));
            }
            handleRowAction(event){
                this.slectedRecords = event.detail.selectedRows;
                console.log('SelecteRecords',JSON.stringify(this.slectedRecords));
            }
            saveHandleAction(event) {
                this.draftValues = event.detail.draftValues;
                console.log('DraftValues',JSON.stringify(this.draftValues));
            }
            picklistChanged(event){
                let dataId = event.detail.data.context;
                let value = event.detail.data.value;
                let changedData = {'Id': dataId, 'value': value};
                console.log('ChangedData',JSON.stringify(changedData));
                this.draftValues = [...this.draftValues,changedData];
                console.log('Id',dataId);
                console.log('value',value);
            }
            handlePaginatorChange(event) {
                console.log(event + 'eventtttt');
                this.slicedSpList = event.detail;
                console.log('sliced data>>>>', this.slicedSpList)
             }
          
}