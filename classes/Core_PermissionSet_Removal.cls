public class Core_PermissionSet_Removal {
    public static void removePermission()
    {
        //Map <PS,list<entitlements>>
        map<String,List<String>> mapPermissionsetEntitlement = new map<String,List<String>>();
        // Map <User,list<PS>>
        map<String,set<String>> mapUserPermissionDelete = new map<String,set<String>>();
        set<String> entitlementNameSet = new set<String>();
        List<String> psNameList = new List<String>();
        //Get list of Entitlements with corresponding permission sets
        List<Core_Entitlement__c> entitlementDetailsList = [select Id, Core_Display_Name__c, Core_Permission_Set_API_Nm__c from Core_Entitlement__c where Core_Permission_Set_API_Nm__c != null];
        for(Core_Entitlement__c ent : entitlementDetailsList){
            if(mapPermissionsetEntitlement.containskey(ent.Core_Permission_Set_API_Nm__c)){
                mapPermissionsetEntitlement.get(ent.Core_Permission_Set_API_Nm__c).add(ent.Core_Display_Name__c);
                entitlementNameSet.add(ent.Core_Display_Name__c);
            }
            else{    
                List<String> EntNameList = new List<String>();
                EntNameList.add(ent.Core_Display_Name__c);
                mapPermissionsetEntitlement.put(ent.Core_Permission_Set_API_Nm__c,EntNameList);
                entitlementNameSet.add(ent.Core_Display_Name__c);
                psNameList.add(ent.Core_Permission_Set_API_Nm__c);
            }
            
        }
        System.debug('mapPermissionsetEntitlement ='+ mapPermissionsetEntitlement);
        System.debug('entitlementNameSet ='+ entitlementNameSet);
        System.debug('psNameList ='+ psNameList);
        
        
        //Removal Logic
        
        for(String psName : psNameList){
            User[] lstUser =
                [
                    SELECT Id,
                    Name,
                    ContactId, Contact.Name,
                    CreatedDate
                    FROM User
                    WHERE IsActive = TRUE
                    AND Profile.Name = 'Partner'
                    AND ContactId IN
                    (
                        SELECT 
                        Core_Contact_Id__c 
                        FROM Core_Contact_Entitlement__c 
                        WHERE Core_Entitlement_Id__r.Core_Display_Name__c IN :mapPermissionsetEntitlement.get(psName)
                        AND Core_Selected__c = False
                        AND Core_Status__c = 'Complete'
                    )
                    AND Id IN
                    (
                        SELECT AssigneeId 
                        FROM PermissionSetAssignment 
                        WHERE PermissionSet.Name = :psName
                    )
                    LIMIT 10 // Check this
                ]; 
            System.debug(psName +'==> lstUser ='+lstUser);
            Boolean flag = false ;
            for(User usr : lstUser){
                list<String> listEntitlement = mapPermissionsetEntitlement.get(psName);
               // map<String,List<Core_Contact_Entitlement__c>> mapUserIdContENt = new map<String,set<Core_Contact_Entitlement__c>>();
               list<Core_Contact_Entitlement__c> conEnt = [select id,Core_Contact_Id__c,Core_Entitlement_Id__c,Core_Selected__c,Core_Status__c,Core_Entitlement_Id__r.Core_Display_Name__c from Core_Contact_Entitlement__c where Core_Contact_Id__c =: usr.ContactId];
                //mapUserIdContENt.put(usr.Id,usr.Core_Contact_Entitlement__r);
                for(String ent : listEntitlement){
                    for(Core_Contact_Entitlement__c contEnt :conEnt ){
                        if(contEnt.Core_Entitlement_Id__r.Core_Display_Name__c == ent && contEnt.Core_Selected__c  && contEnt.Core_Status__c == 'Complete'){
                            flag = true;
                        }                  
                    }
                }
                if(flag == false){
                    if(mapUserPermissionDelete.containskey(usr.Id)){
                        mapUserPermissionDelete.get(usr.Id).add(psName);
                    }
                    else{    
                        set<String> PermissionNm = new set<String>();
                        PermissionNm.add(psName);
                        mapUserPermissionDelete.put((String)usr.Id,PermissionNm);
                    } 
                }
                
            }
        }
        System.debug('Delete Records Map==>' + mapUserPermissionDelete);
        List<PermissionSetAssignment> psaList = [select PermissionSetId,AssigneeId,PermissionSet.Name from PermissionSetAssignment where AssigneeId =: mapUserPermissionDelete.keyset() and PermissionSet.Name In :mapPermissionsetEntitlement.keyset()]; 
        List<PermissionSetAssignment> deletePermissionSets = new list<PermissionSetAssignment>();
        for(PermissionSetAssignment psa : psaList){
            if(mapUserPermissionDelete.get(psa.AssigneeId).contains(psa.PermissionSet.Name)){
                deletePermissionSets.add(psa);
            }            
        }
        system.debug('Delete Records==>'+deletePermissionSets);
       // delete deletePermissionSets;
    }   
}