import { LightningElement, api, track } from 'lwc';
import getFieldsAndRecords from '@salesforce/apex/Core_MDF_GetObjectDetails.getFieldsAndRecords';
import portalBaseURL from '@salesforce/label/c.Core_MDF_PFRCommunityLink';
import communityURLSection from '@salesforce/label/c.Core_MDF_CommunityURLSection';
import orgBaseURL from '@salesforce/label/c.Core_MDF_Environment_URL';

export default class Core_MDF_Generic_Related_List extends LightningElement {
    
    @api recordId;  // record id from record detail page e.g. ''0012v00002WCUdxAAH'
    @api relatedobjectApiName; //kind of related list object API Name e.g. 'Activating Patners'
    //relatedobjectApiName => relatedobjectApiName
    @api strFields; //fldApiNamesList
    @api criteriaFieldAPIName; // This field will be used in WHERE condition e.g.'campaignId'
    //filter condition as a whole
    //additional filter condition -> string input
    @api additionalCriteria;

    @track columns;   //columns for List of fields datatable
    @track tableData;   //data for list of fields datatable
    
    recordCount; //this displays record count inside the () => totalRecords/dataCount
    objectName; //this displays the Object Name whose records are getting displayed => relatedObjLabel
    //additional where condition 
    @api restrictColumnVisiblity;
    @api restrictColumnVisiblityCriteria;

  connectedCallback(){

        //make an implicit call to fetch records from database
         getFieldsAndRecords({ strObjectApiName: this.relatedobjectApiName,
                                strFields: this.strFields,
                                criteriaField: this.criteriaFieldAPIName,
                                criteriaFieldValue: this.recordId,
                                additionalCriteria: this.additionalCriteria
                            })  
            
        
        .then(data=>{       
            let userType;
            //get the entire map
            let records=[];
            let fieldDataList=[];
            let fields = [];
            let fieldsDescribe={};
            if (this.checkForUndefinedEmptyAndNull(data)) {
                userType = data.userType;
                //retrieved listOfRecords 
                records = data.recordsData;
                this.objectName = data.objectLabel;
                fieldDataList = data.fieldDataList;
            } else{
                console.log('error in getFieldsAndRecords:'+data);
            }
            let listOfFields = [];
            listOfFields = this.strFields.split(',');
            
            fieldDataList.map(data=>{
                for (const [key, value] of Object.entries(data)) {
                    fields.push(key);
                    fieldsDescribe[value.fieldName] = value;
                    // fieldsDescribe.push(fieldsDescribe);
                  }
            });
            console.log('fieldsDescribe:'+JSON.stringify(fieldsDescribe));
            let items = []; //local array to prepare columns

            //prepare the column with type = url
            listOfFields.map(element=>{
                let fData;
                if(!(element.includes('__r.'))){
                    let tData = fieldsDescribe[element];
                    console.log('tData : '+tData);
                    fData = tData['dataType'];
                }
                // it will enter this if-block just once
                if(element.includes('__r.') || (fields.includes(element) && fData == 'REFERENCE')){    
                    let fld;
                    if(element.includes('__r.')){
                        let elements = element.split('.');
                        fld = elements[1];
                    }else{
                        fld = element;
                    }
                    items = [...items ,
                    {
                        label: fld, 
                        fieldName: 'URLField',
                        type: 'url', 
                        typeAttributes: { 
                            label: {
                                fieldName: fld
                            },
                            target: '_blank'
                        },
                        sortable: false,
                        hideDefaultActions : true
                    }
                    ];                
                }else {
                        items = [...items ,{label: element, 
                            fieldName: element}];
                        }    
                }); 
                
                //prepare table data
                this.columns = items; 
                console.log('this.columns'+JSON.stringify(this.columns));
                this.tableData = [];
                records.map(item=>{
                    let recData = item;
                    let tdata={};
                    listOfFields.map(fld=>{
                        let elements = fld.split('.');
                        let field;
                        if(fld.includes('.')){
                            field = elements[1];
                            tdata[field] = recData[elements[0]][field];//{ActPartId:'',ActPartner__r:{name:'',id:''}}
                        }else{
                            field = fld;
                            tdata[field] = recData[field];
                        }
                    })
                    this.tableData.push(tdata);
                });
                records = this.tableData;
                console.log('tableData',this.tableData);

                console.log('records',records);

                //create URL with Id and push it into the array
                this.tableData = records.map(item=>{
                    let URLField;
                    listOfFields.map(element=>{
                    let fData;
                    if(!element.includes('__r.')){
                        let tData = fieldsDescribe[element];
                        console.log('tData : '+tData);
                        fData = tData['dataType'];
                    }
                    // it will enter this if-block just once
                    if(element.includes('__r.') || (fields.includes(element) && fData == 'REFERENCE')){    
                        let fld;
                        if(element.includes('__r.')){
                            let elements = element.split('.');
                            fld = elements[0].replace('__r','__c');
                        }else{
                            fld = element;
                        }
                        URLField = userType == 'Internal User' ? orgBaseURL + this.relatedobjectApiName + '/' + item[fld] + '/view':
                                                            portalBaseURL + communityURLSection + item[fld];
                    }
                });
                return {...item,URLField};                     
            });
                console.log('this.tableData 92:'+this.tableData);
                console.log('this.tableData 95:'+JSON.stringify(this.tableData));
                // if(this.relatedobjectApiName == 'Core_MDF_Camp_to_ActPartner__c'){
                //     this.columns = this.columns.filter(col=>col.fieldName !='Core_MDF_Activating_Partner_Account_id__c' );
                // }

            //assign values to display Object Name and Record Count on the screen
            this.recordCount = this.tableData.length;
            this.error = undefined;   
        })
        .catch(error =>{
            this.error = error;
            console.log('error',this.error);
            this.tableData = undefined;
            this.objectName = this.relatedobjectApiName;
        })        
    }

    checkForUndefinedEmptyAndNull(input) {
        if (input !== undefined && input !== null && input !== "") {
            return true;
        } else {
            return false;
        }
    
    }
    //Ealay
    /* Initial field list
    listOfFields = this.strFields.split(',').map(f => f.trim());

    if(this.outcomebasedResult === true) {
    console.log('Outcome-based result is true — removing FlexiPage fields');

    const flexipageFieldsToRemove = (this.restrictColumnVisiblity || '').split(',').map(f => f.trim());

    // Remove only those fields that are in flexipageFieldList
    listOfFields = listOfFields.filter(field => !flexipageFieldsToRemove.includes(field));

    console.log('Final listOfFields after filtering:', listOfFields);*/
}