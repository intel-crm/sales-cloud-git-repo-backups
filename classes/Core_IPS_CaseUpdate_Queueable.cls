/***********************************************************************************************************
* Name 			: Core_IPS_CaseUpdate_Queueable 
* Test Class 	: Core_IPS_CaseUpdate_Queueable_Test
* Author 		: Shipra Bardhan
* Date Created 	: 08/01/2025
* Description 	: Queueable Class to update the case when comments contains Images in the HSD to IPS flow
* Version Updates : 1.0
* LastModified                  Date                   Description
* ------------------------------------------------------------------------------------------------------------                
* Shipra Bardhan             08/01/2025         		PRB10061809
*************************************************************************************************************/ 
public without sharing class Core_IPS_CaseUpdate_Queueable implements Queueable {
    
    private String strCaseList;
    private String strCaseMap;
    static final String CLOSED_TEXT  = 'Closed';
    
    
    public Core_IPS_CaseUpdate_Queueable(String strCaseList, String strCaseMap) {
        this.strCaseList = strCaseList;
        this.strCaseMap = strCaseMap;
    }
    
    public void execute(QueueableContext context) {
        
        Map<Id, Case> caseListMap = new Map<Id, Case>((List<case>)JSON.deserialize(strcaseList, List<Case>.class));
        Map<Id, Case> caseMap = (Map<Id, Case>)JSON.deserialize(strcaseMap, Map<Id, Case>.class);
        Map<Id, Case> caseMapupdated = new Map<Id, Case> ([Select id,status from case where id In :caseListMap.keyset()]);
        List<case> finalCasetoUpdate = new List<case>();
        for(Sobject cs : caseListMap.values()) {
            Map<String, Object> fieldsToValue = cs.getPopulatedFieldsAsMap();
            case caseSobject = new case();
            caseSobject.put('id', cs.Id);
            for(String queriedField: fieldsToValue.keySet()) {
                try {  
                    if(cs.get(queriedField) != caseMap.get(cs.id).get(queriedField)) {
                        if( queriedField =='Core_Sub_Status__c' && caseMapupdated.get(cs.id).get('status') ==CLOSED_TEXT) {
                            continue;
                        }
                        if( queriedField =='Status' && caseMapupdated.get(cs.id).get('status') ==CLOSED_TEXT) {
                            continue;
                        }
                        caseSobject.put(queriedField, cs.get(queriedField));
                    }
                    
                }
                catch(Exception e) {
                    
                }
            }
            finalCasetoUpdate.add(caseSobject);
            
        } 
        if(Case.SObjectType.getDescribe().isUpdateAble()) {
            database.update(finalCasetoUpdate);
        }   
    }  
}