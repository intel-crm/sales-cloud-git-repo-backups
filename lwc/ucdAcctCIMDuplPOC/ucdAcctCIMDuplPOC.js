import { LightningElement,track } from 'lwc';
import getdupCIMId from '@salesforce/apex/UCD_AccountDuplicate.getDuplicateCIMId';
import getRegionList from '@salesforce/apex/UCD_AccountDuplicate.getRegionList';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import tableJS from '@salesforce/resourceUrl/ucdTable';

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
    @track acctList=[];
    @track tableId = 'mytable';
    @track th1 = 'sl';
    @track th1 = 'nm';
    @track sorttable;

    sort(){     
            loadScript(this, tableJS+ '/table.js') 
            .then(()=>{
                 sortTable(0);
                alert('Hiii'+this.sorttable);
             })          
        
    }

    sort(){

    }

    sortTable() {
        let table=[]; 
        let rows; 
        let switching;
        let x;
        let y;
        let shouldSwitch;
        table = this.template.querySelector('table');
        console.log('******************'+JSON.stringify(table));
        switching = true;
        /*Make a loop that will continue until
        no switching has been done:*/
        while (switching) {
          //start by saying: no switching is done:
          switching = false;
          rows = table.rows;
          /*Loop through all table rows (except the
          first, which contains table headers):*/
          for (let i = 1; i < (rows.length - 1); i++) {
            //start by saying there should be no switching:
            shouldSwitch = false;
            /*Get the two elements you want to compare,
            one from current row and one from the next:*/
             x = rows[i].this.template.querySelector("TD")[1];
             y = rows[i + 1].this.template.querySelector("TD")[1];
            //check if the two rows should switch place:
            if (x.innerHTML.toLowerCase() > y.innerHTML.toLowerCase()) {
              //if so, mark as a switch and break the loop:
              shouldSwitch = true;
              break;
            }
          }
          if (shouldSwitch) {
            /*If a switch has been marked, make the switch
            and mark that a switch has been done:*/
            rows[i].parentNode.insertBefore(rows[i + 1], rows[i]);
            switching = true;
          }
        }
      }
    
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
                            console.log('J44 ',this.accMap.length)                                        
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
                               console.log('J86 ',newMap)
                            }
                        }
                    }
                    
                    let regionStg = key+" (CIM with Duplicate Accounts: "+newMap.length +")";
                    this.regMap.push({value:newMap, key:regionStg});
                   
                   
                }
            }
            console.log('******'+JSON.stringify(this.regMap));
            /*for(let i=0;i<regionList.length;i++){
                console.log('123'+regionList[i].Core_Geo__c);
                
                //
               // for(key in this.dupCIMList){    
                
            }*/
           

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
        console.log('1234***'+JSON.stringify(this.regMap));
       // alert(this.regMap.value.value.value.id)
        for(let i=0;i<this.dupMap.length;i++){
            if(cimID === this.dupMap[i].key){
                this.acctList.push(this.dupMap[i]);
            }
        }
        console.log('AAAA***'+JSON.stringify(this.acctList));
        
        this.isModalOpen = true;
    }
    
    closeModal(){
        this.isModalOpen = false;
    }

    
}