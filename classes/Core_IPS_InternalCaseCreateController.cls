// TEst class - Core_IPS_IntCaseCreateControllerTest
public class Core_IPS_InternalCaseCreateController {
    
    /*@AuraEnabled(cacheable=true)
    public static List<String> readFieldSet(String fieldSetName, String ObjectApiName){
        List<String> fieldList = new List<String>();
        for(Schema.FieldSetMember fieldSetMemberObj : Core_Utility.readFieldSet(fieldSetName, ObjectApiName)) {
            fieldList.add(fieldSetMemberObj.getFieldPath());
        } 
        return fieldList;
    }*/
    
    @AuraEnabled(cacheable=true)
    public static List<String> getProjectList(String relatedId){
        List<user> faeUsers = new List<User>();
        List<user> u = new List<User>();
        List<String> projIdList = new List<String>();
        if(relatedId.startswith('003')) {
            u = [select id from user where contactId=:relatedId];
           } else {
            faeUsers = [select id from user where ID=:UserInfo.getUserId()];
           }
        List<Core_ips_Project__Share> projMembers;
        if(faeUsers <> null && faeUsers.size() > 0) {
            projMembers = [select parentid from Core_ips_Project__share where userorgroupId =:faeUsers[0].id and parent.core_status__c='Active' ];  
             if(projMembers <> null && projMembers.size() > 0) {
                for(Core_ips_Project__share member: projMembers) {
                    if(member.parentid!=null) {
                        projIdList.add(member.parentid);
                    }   
                }
            }
        }
        if(u <> null && u.size() > 0) {
            projMembers = [select parentid from Core_ips_Project__share where parent.core_status__c='Active' AND userorgroupId in (SELECT groupid FROM GroupMember where userorgroupid=:u[0].id)];   
           if(projMembers <> null && projMembers.size() > 0){
                for(Core_ips_Project__share member: projMembers) {
                    if(member.parentid!=null) {
                        projIdList.add(member.parentid);
                    }   
                }
            }
        }
        return projIdList;
    }
    
    @AuraEnabled(cacheable=true)
    public static Map<String, String> displayProductVariant(String selectedProductId) {
        List<SelectOption> variants = Product_Variant_Utility.displayProductVariant(selectedProductId);   
        Map<String, String> proVarList = new Map<String, String>();
        for(Integer i=0;variants!=null && i<(variants.size()/999)+1;i++){
            for(Integer j=(i*999);(j<(i*999)+999) && j<variants.size() ;j++){
                if(!variants.get(j).getDisabled()) {
                	proVarList.put(variants.get(j).getLabel(), variants.get(j).getValue());    
                }
            }
        }
        System.debug('proVarList in aura enbled function ' + proVarList);
        return proVarList;        
    }   
    
    @AuraEnabled(cacheable=true)
    public static Map<String, String> displayProductVariantNAC(String selectedProductId) {
        List<SelectOption> variants = Product_Variant_Utility.displayProductVariant_NAC(selectedProductId);   
        Map<String, String> proVarList = new Map<String, String>();
        for(Integer i=0;variants!=null && i<(variants.size()/999)+1;i++){
            for(Integer j=(i*999);(j<(i*999)+999) && j<variants.size() ;j++){
                if(!variants.get(j).getDisabled()) {
                	proVarList.put(variants.get(j).getLabel(), variants.get(j).getValue());    
                }
                System.debug('proVarList '+proVarList);
            }
        }
        System.debug('proVarList in aura enbled function ' + proVarList);
        return proVarList;        
    } 
}