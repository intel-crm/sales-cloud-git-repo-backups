import { LightningElement,track,api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { utilityModule} from 'c/core_MDF_utilityModule';
import getFieldsList from  '@salesforce/apex/Core_MDF_CCP_GetFieldsList.getObjectFields';
import getFieldType from '@salesforce/apex/Core_MDF_CCP_GetFieldsList.getFieldsType';
import getPickListValues from '@salesforce/apex/Core_MDF_CCP_GetFieldsList.getPickListValues';
//import getResult from '@salesforce/apex/Core_MDF_CCP_MultiLookup.getResult';

export default class Core_MDF_CCP_filterComponent extends LightningElement {
    @track addError=false;
    @track index_value;
    @track errorFlag=false;
    @track errorFilter='';
    @track highestValue=0;
    @track textAreaInputfirst='';
    @track textQueryfirst='';
    @track textAreaInput='';
    @track textQuery='';
    @track filterOutput='';
    @track filterResult='';
    @track filterOutputQuery='';
    @track parentFlag=true;
    @track likeOperator=false;
   // @track booleanOpearator='';
    @api objectname;  
    @track valueOperator;
    @track valueOperatorBoolean;
    @track options;
    @track pickListValue;
    @track valueFieldApi;
    @track pickList;
    @track result;
    @track valueField;
    @track operator='';
    @track operatorBoolean='';
    @track valueText='';
    @track filter=[];
    @track pillFlag=false;
    @track dateVisible=false;
    @track dateTimeVisible=false;
    @track comboboxVisible=false;
    @track radioVisible=false;
    @track textboxVisible=false;
    @track fieldType;
    @track dateValue;
    @track dateTimeValue;
    @track booleanValue;
    @track valuePass='';
    @track booleanFlag=false;
    @track flag_valueFieldApi=false;
    @track flag_operator=false;
    @track flag_operatorBoolean=false;
    @track flag_valueText=false;
    @track flag_picklist=false;
    @track flag_dateTime=false;
    @track flag_date=false;
    @track flag_boolean=false;
    @track flag_error=false;

   
    Utility = new utilityModule();
    get optionsRadio() {
        return [
            { label: 'TRUE', value: 'TRUE' },
            { label: 'FALSE', value: 'FALSE' },
        ];
    }

    get operatorType(){
        return [
            { label: '', value: '' },
            { label: 'AND', value: 'AND' },
            { label: 'OR', value: 'OR' },
        ];

    }
    
    @track labelItems = [
      
    ];
    @track labelItemsResults = [
      
    ];
    @track labelFilterResult = [
      
    ];
    @track storeResult=[

    ];

   @track operationBooleanList=[ { 
    'label':'equals',
    'value':'='
    },
    { 
    'label':'not equal to',
    'value':'!='
    }];

    @track operationList =[
        { 
            'label':'equals',
            'value':'='
        },
        { 
            'label':'not equal to',
            'value':'!='
        },
        { 
            'label':'less than',
            'value':'<'
        },
        { 
            'label':'greater than',
            'value':'>'
        },
        { 
            'label':'less or equal',
            'value':'<='
        },
        { 
            'label':'greater or equal',
            'value':'>='
        },
        { 
            'label':'contains',
            'value':'contains'
        },
        { 
            'label':'does not contain',
            'value':'does not contain'
        },
        { 
            'label':'starts with',
            'value':'starts with'
        },
        { 
            'label':'ends with',
            'value':'ends with'
        }
    ] 


    connectedCallback(){
      
     getFieldsList({
            objName: this.objectname,
            })
                .then(data => {
                   
                this.options = data;
                })
                .catch(error => {
                    
                });
             
      }


    handlefields(event){
        this.valueFieldApi=event.target.value;
        this.valueField= event.target.options.find(opt => opt.value === event.detail.value).label;
        getFieldType({
            objName: this.objectname,
            })
            .then(data => {
                this.result = data;
                this.result.forEach(element => {
                if(element.label==this.valueField){
                     this.fieldType=element.value;

         if(this.fieldType=='STRING' ||this.fieldType=='INTEGER'||this.fieldType=='ADDRESS' ||this.fieldType=='REFERENCE')
            {
                this.textboxVisible=true;
                this.radioVisible=false;
                this.dateVisible=false;
                this.dateTimeVisible=false;
                this.comboboxVisible=false;
                this.booleanFlag=false;
            }
            else if(this.fieldType=='ID'){
                this.textboxVisible=true;
                this.radioVisible=false;
                this.dateVisible=false;
                this.dateTimeVisible=false;
                this.comboboxVisible=false;
                this.booleanFlag=true;
            }
            else if(this.fieldType=='BOOLEAN')
             {
                 this.radioVisible=true;
                 this.booleanFlag=true;
                 this.textboxVisible=false;
                 this.dateVisible=false;
                 this.dateTimeVisible=false;
                 this.comboboxVisible=false;
             }
             else if (this.fieldType=='DATE' )
             {
              this.dateVisible=true;
              this.textboxVisible=false;
              this.radioVisible=false;
              this.dateTimeVisible=false;
              this.comboboxVisible=false;
              this.booleanFlag=false;

             }
             else if(this.fieldType=='DATETIME')
             {
                this.dateTimeVisible=true;  
                this.dateVisible=false;
                this.textboxVisible=false;
                this.radioVisible=false;
                this.comboboxVisible=false;
                this.booleanFlag=false;
             }
             else if(this.fieldType=='MULTIPICKLIST' || this.fieldType=='PICKLIST')
            {   
                this.comboboxVisible=true;
                this.dateTimeVisible=false;  
                this.dateVisible=false;
                this.textboxVisible=false;
                this.radioVisible=false;
                this.booleanFlag=false;
                getPickListValues({objApiName:this.objectname,fieldName:this.valueFieldApi})
               .then(data => {
                this.pickList = data;
                })
                .catch(error => {
                  
                }); 
            }
            else
            {
                this.textboxVisible=true;
                this.booleanFlag=false;
                this.radioVisible=false;
                this.dateVisible=false;
                this.dateTimeVisible=false;
                this.comboboxVisible=false;
            }
        }
            })
          
            })

       .catch(error => {
                    
                });

      
    }

    handleoperatorBoolean(event){
        this.operatorBoolean=event.target.value;
    }

    handleoperator(event){ 
        this.operator=event.target.value; 
        if(this.operator=='contains' || this.operator =='does not contain'||this.operator=='starts with'||this.operator=='ends with')
        {
          this.likeOperator=true;
        }
        else{
            this.likeOperator=false;
        }

    }   
    handlevalue(event){
      this.valueText=event.target.value;
    }

    ontextArea(event){
        this.filterOutput=event.target.value;
    }
    handleRemove(event){

            this.filterOutput='';
            this.filterOutputQuery='';
            this.textAreaInput='';
            this.textQuery='';
            this.errorFlag=false;
            this.errorFilter='';
            const pillIndex = event.detail.index ? event.detail.index : event.detail.name;
            
            const itempill = this.labelItems;
            itempill.splice(pillIndex, 1);       
            this.labelItems = [...itempill];
            const itempillnew = this.labelItemsResults;
            itempillnew.splice(pillIndex, 1);       
            this.labelItemsResults = [...itempillnew];
        
        if(this.labelItemsResults.length==0){
                  this.highestValue=0;
              }
           else{
            this.labelItemsResults.forEach( element=>{
                if(element.value>=1)
                {
                    this.highestValue=element.value;
                }
                const eValue = JSON.stringify(element.value);
                const result = this.Utility.sanitize(eValue);
                
		        if(element.value==1)
                 {      
                     
                     this.textAreaInput=result+' ';
                     
                     this.textQuery=element.label+' ';
 
                 }
                   else{ 
                        
                        this.textAreaInput='AND'+' '+result+' ';
                        
                        this.textQuery='AND'+' '+element.label+' ';
                 }
		 
            this.filterOutput+=this.textAreaInput;
            this.filterOutputQuery+=this.textQuery;
               
            })
            let arrayResult=this.filterOutput.split(' ');
            if(arrayResult[0]=='AND'||arrayResult[0]=='and'){
                this.errorFlag=true;
                this.errorFilter='Filter condition is not appropriate';
            }
           
           }
            

            this.parentFlag=false;
            const passToMaintance=new CustomEvent( "passtable",{
                detail:this.parentFlag
            });
            this.dispatchEvent(passToMaintance);
    }
    handleAdd(event){
        this.flag_valueFieldApi=false;
        this.flag_operator=false;
        this.flag_operatorBoolean=false;
        this.flag_valueText=false;
        this.flag_picklist=false;
        this.flag_dateTime=false;
        this.flag_date=false;
        this.flag_boolean=false;
        this.flag_error=false;
        this.addError=false;

        if(this.valueFieldApi==undefined||this.valueFieldApi==''){
            this.flag_valueFieldApi=true;
         }
         if(this.operatorBoolean==undefined ||this.operatorBoolean==''){
              this.flag_operatorBoolean=true;
        }
         if(this.operator==undefined ||this.operator==''){
             this.flag_operator=true;
        }
         if(this.valueText==undefined ||this.valueText==''){
             this.flag_valueText=true;
        }
         if(this.pickListValue==undefined ||this.pickListValue==''){
             this.flag_picklist=true;
         }
         if(this.dateValue==undefined ||this.dateValue==''){
            this.flag_date=true;
        }
       if(this.dateTimeValue==undefined ||this.dateTimeValue==''){
             this.flag_dateTime=true;
         }
        if(this.booleanValue==undefined ||this.booleanValue==''){
             this.flag_boolean=true;
         }


         if(this.comboboxVisible==true){
          if(this.flag_valueFieldApi==true||this.flag_operator==true||this.flag_picklist==true){
                this.flag_error=true;
           }
         }
         else if(this.textboxVisible==true){
            if((this.flag_valueFieldApi==true||this.flag_operator==true||this.flag_valueText==true)&& (this.flag_valueFieldApi==true||this.flag_operatorBoolean==true||this.flag_valueText==true)){
                this.flag_error=true;
           }
           
         }

         else if(this.dateTimeVisible==true){
            if(this.flag_valueFieldApi==true||this.flag_operator==true||this.flag_dateTime==true){
                this.flag_error=true;
          }
         }
         else if(this.dateVisible==true){
            if(this.flag_valueFieldApi==true||this.flag_operator==true||this.flag_date==true){
                this.flag_error=true;
           }

         }
       else if(this.radioVisible==true){
        if(this.flag_valueFieldApi==true||this.flag_operatorBoolean==true||this.flag_boolean==true){
            this.flag_error=true;
             }
       } 
       else{
        this.flag_error=true;
       } 


       if(this.flag_error==true)
             {   
                    const evt = new ShowToastEvent({ 
                    variant:'error',
                    title: '',
                    message:'Please select atleast one filter condition'
                    });
                     this.dispatchEvent(evt)
                    this.addError=true;
            }
          
           if(this.addError==false){ 
            this.pillFlag=true;
            let rec={};
            let recNew={};

            this.valuePass=this.valueText;
           if(this.textboxVisible==true && (this.likeOperator==false)){
            this.valuePass="'"+this.valueText+"'";

           }
           else if(this.dateTimeVisible==true){
            this.valuePass=this.dateTimeValue;
           }
           else if(this.dateVisible==true){
           this.valuePass=this.dateValue;
         
           }
           else if(this.radioVisible==true)
           {
            this.valuePass=this.booleanValue;
           }
           else if(this.comboboxVisible==true){
            this.valuePass="'"+this.pickListValue+"'";
         
           }
           else{

            if(this.likeOperator==false){
                this.valuePass="'"+this.valueText+"'";
            }
          }

           if(this.booleanFlag==true){
           //if(this.booleanOpearator=='')
        //    {
            if(this.operator=='contains'){
                rec["label"]=(this.valueField+" "+this.operatorBoolean+" "+"'%"+this.valuePass+"%'");
                recNew["label"]=(this.valueFieldApi+" "+"LIKE"+" "+"'%"+this.valuePass+"%'");
             }
             else if(this.operator=='does not contain')
             {
                rec["label"]=("NOT ("+this.valueField+" "+this.operatorBoolean+" "+"'%"+this.valuePass+"%'"+""+")");
                recNew["label"]=("NOT ("+this.valueFieldApi+" "+"LIKE"+" "+"'%"+this.valuePass+"%'"+""+")");
             }
             else if(this.operator=='starts with'){
                rec["label"]=(this.valueField+" "+this.operatorBoolean+" "+"'%"+this.valuePass+"'");
                recNew["label"]=(this.valueFieldApi+" "+"LIKE"+" "+"'%"+this.valuePass+"'");
            
             }
             else if(this.operator=='ends with'){
                rec["label"]=(this.valueField+" "+this.operatorBoolean+" "+"'"+this.valuePass+"%'");
                recNew["label"]=(this.valueFieldApi+" "+"LIKE"+" "+"'"+this.valuePass+"%'");
            
            }
              else{ 
                 rec["label"]=(this.valueField+" "+this.operatorBoolean+" "+this.valuePass);
                 recNew["label"]=(this.valueFieldApi+" "+this.operatorBoolean+" "+this.valuePass);
                 

           }
          
            
      /*  }
        else{
              rec["label"]=(this.booleanOpearator);
              recNew["label"]=(this.booleanOpearator);
              this.booleanOpearator='';
        }*/
           }
       else{ 
       // if(this.booleanOpearator=='')
       // { 
        if(this.operator=='contains'){
            rec["label"]=(this.valueField+" "+this.operator+" "+"'%"+this.valuePass+"%'");
            recNew["label"]=(this.valueFieldApi+" "+"LIKE"+" "+"'%"+this.valuePass+"%'");
         }
         else if(this.operator=='does not contain')
         {
            rec["label"]=("NOT ("+this.valueField+" "+this.operator+" "+"'%"+this.valuePass+"%'"+""+")");
            recNew["label"]=("NOT ("+this.valueFieldApi+" "+"LIKE"+" "+"'%"+this.valuePass+"%'"+""+")");
         }
         else if(this.operator=='starts with'){
            rec["label"]=(this.valueField+" "+this.operator+" "+"'%"+this.valuePass+"'");
            recNew["label"]=(this.valueFieldApi+" "+"LIKE"+" "+"'%"+this.valuePass+"'");
        
         }
         else if(this.operator=='ends with'){
            rec["label"]=(this.valueField+" "+this.operator+" "+"'"+this.valuePass+"%'");
            recNew["label"]=(this.valueFieldApi+" "+"LIKE"+" "+"'"+this.valuePass+"%'");
        
          }
         else{
              rec["label"]=(this.valueField+" "+this.operator+" "+this.valuePass);
              recNew["label"]=(this.valueFieldApi+" "+this.operator+" "+this.valuePass);
              
             }
       //  }
       /* else
        {
              rec["label"]=(this.booleanOpearator);
              recNew["label"]=(this.booleanOpearator);
              this.booleanOpearator='';
             
        }  */
        }
            
          

            if(this.highestValue!=0 ){
            rec["value"]=this.highestValue+1;
            recNew["value"]=this.highestValue+1;
            }
            else{
                rec["value"]=this.labelItemsResults.length+1;
                recNew["value"]=this.labelItemsResults.length+1;
            }
            this.labelItems.push(rec);
            this.labelItemsResults.push(recNew);
               
            this.labelItemsResults.forEach( element=>{
                if(this.highestValue<element.value)
                {
                    this.highestValue=element.value;
                }
                

            })


           
            //this.labelFilterResult.push(labelFilter);

           
           
            this.labelItemsResults.forEach( element=>{
                const eValue = JSON.stringify(element.value);
                const result = this.Utility.sanitize(eValue);
                
		        if(element.value==1)
                 {      
                     
                     this.textAreaInput=result+' ';
                     
                     this.textQuery=element.label+' ';
 
                 }
                   else{ 
                        
                        this.textAreaInput='AND'+' '+result+' ';
                        
                        this.textQuery='AND'+' '+element.label+' ';
                 }
                
               
            })
            this.filterOutput+=this.textAreaInput;
            this.filterOutputQuery+=this.textQuery;

           


            this.parentFlag=false;
            const passToMaintance=new CustomEvent( "passtable",{
                detail:this.parentFlag
            });
            this.dispatchEvent(passToMaintance);
		   }
    }
    handleCancel(){
        if(this.textboxVisible==true){
            this.valueText='';
           }
           else if(this.dateTimeVisible==true){
            this.dateTimeValue='';
           }
           else if(this.dateVisible==true){
           this.dateValue='';
         
           }
           else if(this.radioVisible==true)
           {
            this.booleanValue='';
           }
           else if(this.comboboxVisible==true){
            this.pickListValue='';
         
           }
           else{
           this.valueText='';
         
           }



    }
    handleCombo(event){
        this.pickListValue=event.target.value; 

    }
    handleDateValue(event){
        this.dateTimeValue=event.target.value;
    }
    handleDate(event){
         this.dateValue=event.target.value;
        
    }
    handleRadio(event){
        this.booleanValue=event.target.value;
    }
  /*  handleOperatorType(event){
        this.booleanOpearator=event.target.value;
    }*/

    handleApply(){
         this.index_value=1;
         this.filterResult='';
         this.storeResult=[];
         this.filterResult=this.filterOutput+' ';
        // this.filterResult=this.filterResult.replaceAll(" ", "");
         this.filterResult=this.filterResult.replace(/\s+/g, '*&');
         this.labelItemsResults.forEach(element => {
            if(this.filterResult.substr(element.value))
            {   
                let output={};
                output["value"]=element.label;
                this.storeResult.push(output);
               // this.filterResult=this.filterResult.replace(element.value,element.label);
            }
          })
      
        

       /*  this.storeResult.forEach(element=> {
            this.filterResult=this.filterResult.replace(this.index_value+'_',' '+element.value+' ');
            
            this.index_value=this.index_value+1;
         })*/

         this.storeResult.forEach(element=> {
            if(this.filterResult.includes(this.index_value+'*&')){
            this.filterResult=this.filterResult.replace(this.index_value+'*&',' '+element.value+' ');
           
            }
            else{
            this.filterResult=this.filterResult.replace('*&'+this.index_value,' '+element.value+' ');
           
            }
            this.index_value=this.index_value+1;
            })


         //this.index_value=1;
        
         this.filterResult=this.filterResult.replaceAll('*&','');
         //this.query='';
        //this.labelItemsResults.forEach(element => {
           // this.query+=element.label+",";
       // })
        
        if(this.filterResult!=''){
            const evt = new ShowToastEvent({
                variant:'success',
                title: '',
                message:'Filter applied successfully'
                });
                 this.dispatchEvent(evt)
        }
        

        const passToParent=new CustomEvent( "passquery",{
            detail:this.filterResult
        });
        this.dispatchEvent(passToParent);
      

    }
}