import { LightningElement,track } from 'lwc';
import getdupCIMId from '@salesforce/apex/UCD_AccountDuplicate.getDuplicateCIMId';
import getRegionList from '@salesforce/apex/UCD_AccountDuplicate.getRegionList';

export default class UcdAcctCIMDuplicate extends LightningElement {

    //@wire (getdupCIMId)
    //@track dupCIMList;
    @track cimValue;
    @track showTable = false;
    @track dupMap=[];
  //  @track accMap=[];
    @track dupCIMList;
    @track accMap =[];
    @track regMap=[];
    @track acctList;
    @track finalMap = [];

    @track sortList=[];



    connectedCallback(){
        
        getdupCIMId()
        .then(result => {
          
            var key;
            this.dupCIMList = result;         
            for(key in this.dupCIMList){            
                if (Object.prototype.hasOwnProperty.call(this.dupCIMList, key)) {
                    // this.dupMap.push({value:this.dupCIMList[key], key:key}); 
                    let contactsize=[];
                    this.accMap=[]; 
                    contactsize= this.dupCIMList[key];
                    //console.log('&&&'+JSON.stringify(contactsize)); 
                            for(let j=0;j<contactsize.length;j++){   
                               // console.log('+++'+contactsize[j]);   
                                let cont = contactsize[j].Contacts;
                                let consize = 0;
                                if(cont != null){
                                    consize = contactsize[j].Contacts.length;
                                }   
                                this.accMap.push({value:contactsize[j], key:consize});                                                                                            
                            }                               
                            this.dupMap.push({value:this.accMap, key:key});    
                            this.sortList.push(this.accMap.length);                                      
                }               
            }
          //  console.log('123'+JSON.stringify(this.dupMap));   
            
         /*   let contactsize=[];
            contactsize= this.dupMap;
            console.log('&&&'+contactsize.length); 
            for(let i=0;i<contactsize.length;i++){            
                    let acct=contactsize[i].value;
                    console.log('+++'+acct.length);      
                    for(let j=0;j<acct.length;j++){   
                        let cont = acct[j].Contacts;
                        let consize = 0;
                        if(cont != null){
                            consize = acct[j].Contacts.length;
                            console.log('^^^'+ consize);
                        }   
                        this.accMap.push({value:acct[j], key:consize});                               
                    }                                      
            }*/      
           
          
        })
        .catch(error => {
            this.error = error;
        });

        getRegionList()
        .then(result => {
            let regionList=[];
            regionList = result;
            for(let key in regionList){  
                if (Object.prototype.hasOwnProperty.call(regionList, key)) {
                    //this.regMap.push({value:regionList[key], key:key}); 
                    let existMap = regionList[key];
                    let newMap=[];
                    for(let k=0;k<existMap.length;k++){
                        for(let j= 0;j<this.dupMap.length;j++){    
                            let cimID = this.dupMap[j].key.split('(');                           
                            if(cimID[0] === existMap[k].Core_CIM_ID__c){ 
                               // newMap.push({value:this.dupMap[j], key:key});                                  
                               newMap.push(this.dupMap[j]);
                            }
                        }
                    }
                    
                    let regionStg = key+" (No.of CIM with Duplicate Accounts: "+newMap.length +")";
                    this.regMap.push({value:newMap, key:regionStg});
                   
                   
                }
            }
            console.log('******'+JSON.stringify(this.sortList.sort()));
            for(let i=0;i<this.regMap.length;i++){
            for(let j = 0;j<this.sortList.length;j++){
                if(this.sortList[j] === this.regMap[i].value.length){
                    this.finalMap.push(this.regMap[i]);
                }

            }
            }
            console.log('***'+JSON.stringify(this.finalMap));


        })
        .catch(error => {
            this.error = error;
        });
    }

    navigateToDetail(event){
        let recId = event.target.value;
        let sfdcBaseURL = window.location.origin;
        let acctUrl = sfdcBaseURL + '/' + recId;
        window.open(acctUrl);
    }

    @track isModalOpen;
    fetchRecord(event){
        let cimID = event.target.name;
        this.acctList=[];
        console.log('1234***'+cimID);
        for(let i=0;i<this.dupMap.length;i++){
            if(cimID === this.dupMap[i].key){
                this.acctList.push(this.dupMap[i]);
            }
        }
        console.log('1234***'+JSON.stringify(this.acctList));
        this.isModalOpen = true;
    }

    closeModal(){
        this.isModalOpen = false;
    }
}