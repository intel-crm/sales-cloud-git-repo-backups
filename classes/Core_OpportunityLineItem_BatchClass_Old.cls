/**************************************************************************************
Apex Class Name:  Core_OpportunityLineItem_BatchClass
Version     : 1.0 
Created Date: 22 June 2017
Function    : Class to recalculate opportunity line item BU Short name and this batch class runs at every 8 hours
Modification Log :
* Developer           Date                    Description
* ---------------------------------------------------------------------------- 
* Rajesh Kumar        04/04/2018              US102413-Removed Filter Condition 'Write In product' in the Query.
* Rajesh Kumar        07/02/2018              US93858-Added logic for Update BU mapping logic to enter and continue to update the BU data on opportunities and products that are lost and cancelled).                                                     
* Rajesh kumar        01/08/2017              Insert BU calculation failed record in exception object.             
* Ajay DS             22/06/2017              Original Version 
*/
global class Core_OpportunityLineItem_BatchClass_Old implements Database.Batchable<sObject>, Database.Stateful{   
    public static List<Core_BU_Mapping_Table__c> listOfBUShortName= new List<Core_BU_Mapping_Table__c>();
    public List<OpportunityLineItem> failedList= new List<OpportunityLineItem>();
    public static Integer nextChk=0000;
    public static Integer tempxtChk = 0000;     
     
    /*
    * Method name  : Start()- Batch class
    * Description  : Queries the values from BU Mapping table and Opty line item to process
    * Return Type  : List of records.
    * Parameter    : Batch context
    */    
    global Database.QueryLocator start(Database.BatchableContext BC){  
        String query = 'SELECT Core_product2_division__c,Core_BU_Product_Segment__c,Core_BU_ShortName__c,Core_BU_Short_Name__c,Core_Division__c,Core_Product_Application__c,Core_Product_Segment__c,Core_Product_Type__c,Id,OpportunityId FROM OpportunityLineItem where Core_Status__c IN (\'Pending\', \'Design Win\', \'Deleted\', \'On Hold\', \'Production Win\', \'Approved\', \'Win Submitted\', \'Win Approved\')';                                    
        return Database.getQueryLocator(query);
    }    
    /*
    * Method name  : execute()- Batch class
    * Description  : Process the records to update BU Shortname Opty line items
    * Return Type  : VOID
    * Parameter    : Batch context and Scope
    */  
    global void execute(Database.BatchableContext BC, List<OpportunityLineItem> scope){            
        Map<OpportunityLineItem,List<Core_BU_Mapping_Table__c>> lineItemBUTableMap = new Map<OpportunityLineItem,List<Core_BU_Mapping_Table__c>>();          
        listOfBUShortName = [SELECT Core_BU_Segment__c,Core_BU_Shortname__c,Core_Division_Shortname__c,Core_Product_Application__c,Core_Product_Segment__c,Core_Weightage__c,Name,Core_Product_Type__c FROM Core_BU_Mapping_Table__c where isDeleted=false];                       
        if(listOfBUShortName.size()>0){           
            for(OpportunityLineItem lineItemObj: scope){                                                             
                        for(Core_BU_Mapping_Table__c mappingTableObj:listOfBUShortName){                        
                            //0001
                            if(mappingTableObj.Core_Product_Type__c==null && 
                            (mappingTableObj.Core_Division_Shortname__c==null) &&
                            mappingTableObj.Core_Product_Segment__c==null && 
                            lineItemObj.Core_Product_Application__c!=null && 
                            mappingTableObj.Core_Product_Application__c==lineItemObj.Core_Product_Application__c){
                                nextChk=0001;
                                lineItemBUTableMap =  alignMapValues(mappingTableObj,lineItemObj,lineItemBUTableMap);
                                System.debug('1'+lineItemBUTableMap.get(lineItemObj).size());  
                                
                            }
                            //0011
                            else if(mappingTableObj.Core_Product_Type__c==null && 
                            (mappingTableObj.Core_Division_Shortname__c==null ) &&
                             lineItemObj.Core_Product_Segment__c!=null && 
                            mappingTableObj.Core_Product_Segment__c==lineItemObj.Core_Product_Segment__c &&
                            mappingTableObj.Core_Product_Application__c==lineItemObj.Core_Product_Application__c && 
                            lineItemObj.Core_Product_Application__c!=null){
                                nextChk=0011;
                                lineItemBUTableMap = alignMapValues(mappingTableObj,lineItemObj,lineItemBUTableMap);
                                System.debug('2'+lineItemBUTableMap.get(lineItemObj).size()); 
                                
                            }
                            //0010
                            else if(mappingTableObj.Core_Product_Type__c==null && 
                            (mappingTableObj.Core_Division_Shortname__c==null ) &&
                            mappingTableObj.Core_Product_Segment__c==lineItemObj.Core_Product_Segment__c && 
                            lineItemObj.Core_Product_Segment__c!=null && 
                            mappingTableObj.Core_Product_Application__c== null){
                                nextChk=0010;
                                lineItemBUTableMap = alignMapValues(mappingTableObj,lineItemObj,lineItemBUTableMap);
                                System.debug('3'+lineItemBUTableMap.get(lineItemObj).size());                           
                                
                            }
                            //0100
                            else if(mappingTableObj.Core_Product_Type__c==null && 
                            (mappingTableObj.Core_Division_Shortname__c==lineItemObj.Core_Division__c  ||((lineItemObj.Core_Division__c==null || lineItemObj.Core_Division__c.isNumeric()) && mappingTableObj.Core_Division_Shortname__c!=null &&
                            lineItemObj.Core_product2_division__c.containsIgnoreCase(mappingTableObj.Core_Division_Shortname__c)) || ((lineItemObj.Core_Division__c==null || lineItemObj.Core_Division__c.isNumeric()) && lineItemObj.Core_product2_division__c.containsIgnoreCase(mappingTableObj.Core_BU_Shortname__c))) &&                            
                            mappingTableObj.Core_Product_Segment__c==null && 
                            mappingTableObj.Core_Product_Application__c== null){
                                nextChk=0100;
                                lineItemBUTableMap = alignMapValues(mappingTableObj,lineItemObj,lineItemBUTableMap);
                                System.debug('4'+lineItemBUTableMap.get(lineItemObj).size());                           
                                
                            }
                            //0101
                            else if(mappingTableObj.Core_Product_Type__c==null && 
                            (mappingTableObj.Core_Division_Shortname__c==lineItemObj.Core_Division__c  ||((lineItemObj.Core_Division__c==null || lineItemObj.Core_Division__c.isNumeric()) && mappingTableObj.Core_Division_Shortname__c!=null &&
                            lineItemObj.Core_product2_division__c.containsIgnoreCase(mappingTableObj.Core_Division_Shortname__c)) || (lineItemObj.Core_product2_division__c.containsIgnoreCase(mappingTableObj.Core_BU_Shortname__c) && (lineItemObj.Core_Division__c==null || lineItemObj.Core_Division__c.isNumeric()))) &&                            
                            mappingTableObj.Core_Product_Segment__c==null && 
                            mappingTableObj.Core_Product_Application__c==lineItemObj.Core_Product_Application__c && 
                            lineItemObj.Core_Product_Application__c!=null){
                                nextChk=0101;
                                lineItemBUTableMap = alignMapValues(mappingTableObj,lineItemObj,lineItemBUTableMap);
                                System.debug('5'+lineItemBUTableMap.get(lineItemObj).size());
                                
                            }
                            //0111
                            else if(mappingTableObj.Core_Product_Type__c==null && 
                             mappingTableObj.Core_Division_Shortname__c!=null &&
                            (mappingTableObj.Core_Division_Shortname__c==lineItemObj.Core_Division__c  ||(lineItemObj.Core_product2_division__c.containsIgnoreCase(mappingTableObj.Core_Division_Shortname__c) && (lineItemObj.Core_Division__c==null || lineItemObj.Core_Division__c.isNumeric())) || (lineItemObj.Core_product2_division__c.containsIgnoreCase(mappingTableObj.Core_BU_Shortname__c) && (lineItemObj.Core_Division__c==null || lineItemObj.Core_Division__c.isNumeric()))) &&                     
                            mappingTableObj.Core_Product_Segment__c==lineItemObj.Core_Product_Segment__c && 
                            mappingTableObj.Core_Product_Application__c==lineItemObj.Core_Product_Application__c && 
                            lineItemObj.Core_Product_Application__c!=null){
                                nextChk=0111;
                                lineItemBUTableMap = alignMapValues(mappingTableObj,lineItemObj,lineItemBUTableMap);
                                System.debug('6'+lineItemBUTableMap.get(lineItemObj).size());
                                
                            }
                            //0110
                            else if(mappingTableObj.Core_Product_Type__c==null && 
                            (mappingTableObj.Core_Division_Shortname__c==lineItemObj.Core_Division__c  ||((lineItemObj.Core_Division__c==null || lineItemObj.Core_Division__c.isNumeric()) && mappingTableObj.Core_Division_Shortname__c!=null && lineItemObj.Core_product2_division__c.containsIgnoreCase(mappingTableObj.Core_Division_Shortname__c))|| (lineItemObj.Core_product2_division__c.containsIgnoreCase(mappingTableObj.Core_BU_Shortname__c)  && (lineItemObj.Core_Division__c==null || lineItemObj.Core_Division__c.isNumeric()))) &&                            
                            mappingTableObj.Core_Product_Segment__c==lineItemObj.Core_Product_Segment__c && 
                            lineItemObj.Core_Product_Segment__c !=null &&
                            mappingTableObj.Core_Product_Application__c== null){
                                nextChk=0110;
                                lineItemBUTableMap = alignMapValues(mappingTableObj,lineItemObj,lineItemBUTableMap);
                                System.debug('7'+lineItemBUTableMap.get(lineItemObj).size());
                                
                            }
                            //1000
                            else if(mappingTableObj.Core_Product_Type__c==lineItemObj.Core_Product_Type__c && 
                            lineItemObj.Core_Product_Type__c!=null && 
                            (mappingTableObj.Core_Division_Shortname__c==null ) &&
                            mappingTableObj.Core_Product_Segment__c==null && 
                            mappingTableObj.Core_Product_Application__c== null){
                                nextChk=1000;
                                lineItemBUTableMap = alignMapValues(mappingTableObj,lineItemObj,lineItemBUTableMap);
                                System.debug('8'+lineItemBUTableMap.get(lineItemObj).size());
                                
                            }
                            //1010
                            else if(mappingTableObj.Core_Product_Type__c==lineItemObj.Core_Product_Type__c && 
                            lineItemObj.Core_Product_Type__c !=null && 
                            (mappingTableObj.Core_Division_Shortname__c==null ) &&
                            mappingTableObj.Core_Product_Segment__c==lineItemObj.Core_Product_Segment__c && 
                            lineItemObj.Core_Product_Segment__c!=null && 
                            mappingTableObj.Core_Product_Application__c== null){
                                nextChk=1010;
                                lineItemBUTableMap = alignMapValues(mappingTableObj,lineItemObj,lineItemBUTableMap);
                                System.debug('9'+lineItemBUTableMap.get(lineItemObj).size());
                                
                            }
                            //1001
                            else if(mappingTableObj.Core_Product_Type__c==lineItemObj.Core_Product_Type__c && 
                            lineItemObj.Core_Product_Type__c!=null &&                             
                            mappingTableObj.Core_Division_Shortname__c==null  &&
                            mappingTableObj.Core_Product_Segment__c==null && 
                            mappingTableObj.Core_Product_Application__c==lineItemObj.Core_Product_Application__c && 
                            lineItemObj.Core_Product_Application__c!=null){
                                nextChk=1001;
                                lineItemBUTableMap = alignMapValues(mappingTableObj,lineItemObj,lineItemBUTableMap);
                                System.debug('10'+lineItemBUTableMap.get(lineItemObj).size());
                                
                            }
                            //1011
                            else if(mappingTableObj.Core_Product_Type__c==lineItemObj.Core_Product_Type__c && 
                            lineItemObj.Core_Product_Type__c !=null && 
                            (mappingTableObj.Core_Division_Shortname__c==null ) &&               
                            mappingTableObj.Core_Product_Segment__c==lineItemObj.Core_Product_Segment__c && 
                            lineItemObj.Core_Product_Segment__c!=null && 
                            mappingTableObj.Core_Product_Application__c==lineItemObj.Core_Product_Application__c && 
                            lineItemObj.Core_Product_Application__c!=null){
                                nextChk=1011;
                                lineItemBUTableMap =  alignMapValues(mappingTableObj,lineItemObj,lineItemBUTableMap);
                                System.debug('11'+lineItemBUTableMap.get(lineItemObj).size());
                                
                            }
                            
                            //1100
                            else if(mappingTableObj.Core_Product_Type__c==lineItemObj.Core_Product_Type__c && 
                            lineItemObj.Core_Product_Type__c !=null && 
                            (mappingTableObj.Core_Division_Shortname__c==lineItemObj.Core_Division__c  ||((lineItemObj.Core_Division__c==null || lineItemObj.Core_Division__c.isNumeric()) && mappingTableObj.Core_Division_Shortname__c!=null && lineItemObj.Core_product2_division__c.containsIgnoreCase(mappingTableObj.Core_Division_Shortname__c)) || (lineItemObj.Core_product2_division__c.containsIgnoreCase(mappingTableObj.Core_BU_Shortname__c)  && (lineItemObj.Core_Division__c==null || lineItemObj.Core_Division__c.isNumeric()))) &&                                        
                            mappingTableObj.Core_Product_Segment__c== null && 
                            mappingTableObj.Core_Product_Application__c== null){
                                nextChk=1100;
                                lineItemBUTableMap =  alignMapValues(mappingTableObj,lineItemObj,lineItemBUTableMap);
                                System.debug('12'+lineItemBUTableMap.get(lineItemObj).size());
                                
                            }
                            //1101
                            else if(mappingTableObj.Core_Product_Type__c==lineItemObj.Core_Product_Type__c && 
                            lineItemObj.Core_Product_Type__c!=null && 
                            (mappingTableObj.Core_Division_Shortname__c==lineItemObj.Core_Division__c  ||((lineItemObj.Core_Division__c==null || lineItemObj.Core_Division__c.isNumeric()) && mappingTableObj.Core_Division_Shortname__c!=null && lineItemObj.Core_product2_division__c.containsIgnoreCase(mappingTableObj.Core_Division_Shortname__c)) || (lineItemObj.Core_product2_division__c.containsIgnoreCase(mappingTableObj.Core_BU_Shortname__c) && (lineItemObj.Core_Division__c==null || lineItemObj.Core_Division__c.isNumeric()))) &&                            
                            mappingTableObj.Core_Product_Segment__c== null && 
                            mappingTableObj.Core_Product_Application__c==lineItemObj.Core_Product_Application__c && 
                            lineItemObj.Core_Product_Application__c!=null){
                                nextChk=1101;
                                lineItemBUTableMap = alignMapValues(mappingTableObj,lineItemObj,lineItemBUTableMap);
                                System.debug('13'+lineItemBUTableMap.get(lineItemObj).size());
                                
                            }
                            //1110
                            else if(mappingTableObj.Core_Product_Type__c==lineItemObj.Core_Product_Type__c && 
                            lineItemObj.Core_Product_Type__c !=null && 
                            (mappingTableObj.Core_Division_Shortname__c==lineItemObj.Core_Division__c  ||((lineItemObj.Core_Division__c==null || lineItemObj.Core_Division__c.isNumeric()) && mappingTableObj.Core_Division_Shortname__c!=null && lineItemObj.Core_product2_division__c.containsIgnoreCase(mappingTableObj.Core_Division_Shortname__c)) || (lineItemObj.Core_product2_division__c.containsIgnoreCase(mappingTableObj.Core_BU_Shortname__c)  && (lineItemObj.Core_Division__c==null || lineItemObj.Core_Division__c.isNumeric()))) &&                            
                            mappingTableObj.Core_Product_Segment__c==lineItemObj.Core_Product_Segment__c && 
                            lineItemObj.Core_Product_Segment__c!=null &&
                            mappingTableObj.Core_Product_Application__c== null){
                                nextChk=1110;
                                lineItemBUTableMap =  alignMapValues(mappingTableObj,lineItemObj,lineItemBUTableMap);
                                System.debug('14'+lineItemBUTableMap.get(lineItemObj).size());
                                
                            }
                            //1111
                            else if(mappingTableObj.Core_Product_Type__c==lineItemObj.Core_Product_Type__c && 
                            lineItemObj.Core_Product_Type__c!=null && 
                            (mappingTableObj.Core_Division_Shortname__c==lineItemObj.Core_Division__c  ||((lineItemObj.Core_Division__c==null || lineItemObj.Core_Division__c.isNumeric()) && mappingTableObj.Core_Division_Shortname__c!=null && lineItemObj.Core_product2_division__c.containsIgnoreCase(mappingTableObj.Core_Division_Shortname__c)) || (lineItemObj.Core_product2_division__c.contains(mappingTableObj.Core_BU_Shortname__c)  && (lineItemObj.Core_Division__c==null || lineItemObj.Core_Division__c.isNumeric()))) &&                            
                            mappingTableObj.Core_Product_Segment__c==lineItemObj.Core_Product_Segment__c && 
                            lineItemObj.Core_Product_Segment__c !=null && 
                            mappingTableObj.Core_Product_Application__c==lineItemObj.Core_Product_Application__c && 
                            lineItemObj.Core_Product_Application__c!=null){
                                nextChk=1111;
                                lineItemBUTableMap = alignMapValues(mappingTableObj,lineItemObj,lineItemBUTableMap);
                                System.debug('15'+lineItemBUTableMap.get(lineItemObj).size());
                                
                            }
                        }
                    //}
                if(lineItemBUTableMap.get(lineItemObj)!=null && lineItemBUTableMap.get(lineItemObj).size()==1){
                    lineItemObj.Core_BU_Mapping_record__c = lineItemBUTableMap.get(lineItemObj)[0].Id;                      
                    
                }else if(lineItemBUTableMap.get(lineItemObj)==null || lineItemBUTableMap.get(lineItemObj).size()>1 || lineItemBUTableMap.get(lineItemObj).size()==0){
                     //************************** to create a BU mapping calculation failed log in exception object****************************************//
                    failedList.add(lineItemObj);                      
                } 
                                                
            }  
             //update scope;          
            try{
                Database.update(scope);
            }catch(Exception ex){
                System.debug('Exception occured:'+ex.getMessage());
                 Core_OpportunityLineItemHandler.Insert_logexception(scope,ex.getmessage()); 
            }
        }
    }  
    
/********************************************************************************************************************
Method Name  :  Insert_logexception
Version      : 1.0 
Created Date : 31/7/2017
Function     : This Method used to create a BU Mapping  calculation failed records in Exception object
* Developer                   Date                   Description
* ----------------------------------------------------------------------------
* Rajesh                     06/27/2017            Added for code BU information has not been calculated since crietria has not match with BU mapping table.

*******************************************************************************************************************/   
    global void finish(Database.BatchableContext BC){   
              if(failedList.size() >0)
              Core_OpportunityLineItemHandler.Insert_logexception(failedList,label.Core_BU_ExceptionMsg);              
    }
    
    /*
    * Method name  : alignMapValues()
    * Description  : Creates a Map of maultiple matching records and removes existing if it doesnt match with OLI record while checking fornother fields.
    * Return Type  : Map<OpportunityLineItem,list<Core_BU_Mapping_Table__c>>
    * Parameter    : (Core_BU_Mapping_Table__c mappingObj,OpportunityLineItem lItemObj, Map<OpportunityLineItem,list<Core_BU_Mapping_Table__c>> buMap.
    */ 
    private static  Map<OpportunityLineItem,list<Core_BU_Mapping_Table__c>> alignMapValues(Core_BU_Mapping_Table__c mappingObj,OpportunityLineItem lItemObj, Map<OpportunityLineItem,list<Core_BU_Mapping_Table__c>> buMap){
        List<Core_BU_Mapping_Table__c> buMappingList = new List<Core_BU_Mapping_Table__c>();        
        List<Core_BU_Mapping_Table__c> tempBUMappingList = new List<Core_BU_Mapping_Table__c>();        
        if(!buMap.containsKey(lItemObj)){
                buMappingList.add(mappingObj);
                buMap.put(lItemObj,buMappingList);  
                System.debug(tempxtChk+'1st value--'+nextChk);
                tempxtChk=nextChk;
        }else {                  
                buMappingList = buMap.get(lItemObj);
                
                for(Core_BU_Mapping_Table__c mapTable:buMappingList){                     
                    System.debug(tempxtChk+'2equals--'+nextChk+'##'+lItemObj.Core_Division__c+'##'+mappingObj.Core_Division_Shortname__c+'##'+!lItemObj.Core_product2_division__c.containsIgnoreCase(mapTable.Core_BU_Shortname__c) );
                    if((lItemObj.Core_product2_division__c.containsIgnoreCase(mapTable.Core_BU_Shortname__c) || lItemObj.Core_product2_division__c.containsIgnoreCase(mappingObj.Core_BU_Shortname__c) || (mapTable.Core_Division_Shortname__c!=null && lItemObj.Core_Division__c==null && lItemObj.Core_product2_division__c.containsIgnoreCase(mapTable.Core_Division_Shortname__c)) || (mappingObj.Core_Division_Shortname__c!=null && lItemObj.Core_Division__c==null && lItemObj.Core_product2_division__c.containsIgnoreCase(mappingObj.Core_Division_Shortname__c))||(String.isBlank(mappingObj.Core_Product_Segment__c) &&  !String.isBlank(mappingObj.Core_Product_Application__c)))&& mapTable.Core_Weightage__c <= mappingObj.Core_Weightage__c ){                     
                        tempBUMappingList.add(mappingObj); 
                        System.debug('1equals--');
                    }else if(mapTable.Core_Weightage__c < mappingObj.Core_Weightage__c){
                        tempBUMappingList.add(mappingObj); 
                        System.debug('less than--');
                    }else if(mapTable.Core_Weightage__c > mappingObj.Core_Weightage__c){
                        tempBUMappingList.add(mapTable); 
                        System.debug('greater than--');
                    }else if(tempxtChk>nextChk && mappingObj.Core_Division_Shortname__c==null && lItemObj.Core_Division__c==null && mapTable.Core_Weightage__c <= mappingObj.Core_Weightage__c && !lItemObj.Core_product2_division__c.containsIgnoreCase(mapTable.Core_BU_Shortname__c)|| (mapTable.Core_Weightage__c <= mappingObj.Core_Weightage__c && String.isBlank(mappingObj.Core_Product_Segment__c) && !String.isBlank( mappingObj.Core_Product_Application__c)) || (mapTable.Core_Weightage__c <= mappingObj.Core_Weightage__c && !String.isBlank(mappingObj.Core_Product_Segment__c))){
                        tempBUMappingList.add(mapTable); 
                    }
                    tempxtChk=nextChk;
                } 
                buMap.put(lItemObj,tempBUMappingList);              
        }       
        
        return buMap;
    }
   
  
}