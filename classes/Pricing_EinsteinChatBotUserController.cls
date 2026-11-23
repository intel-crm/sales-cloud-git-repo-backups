public class Pricing_EinsteinChatBotUserController {
	public class UserInput { 
        @InvocableVariable( required=true ) 
        public String employeeEmail; 
    }
    
    public class UserOutPut {         
        @InvocableVariable( required=true ) 
        public String sRoleAssigned;  
    }
    
    @InvocableMethod(label='Check User Access') 
    public static List<UserOutPut> checkUserAccess(List<UserInput> listInputs) { 
     	List < UserOutPut > objOutputs = new List < UserOutPut >();
        UserOutPut objOutput = new UserOutPut(); 
        Set < String > externalPS = new Set < String > ();
        integer count = 0;
        externalPS.addAll(new List < String > ((Label.Pricing_Tender_PermissionSets_AllExternal).split(':')));
		List<User> userRecord = [Select Id,Name,Profile.Name,IsActive from User where Email =: listInputs[0].employeeEmail and IsActive= true LIMIT 1 ];
        
        if(userRecord.size() > 0){
            count = [SELECT count() FROM PermissionSetAssignment
                         WHERE AssigneeId = : userRecord[0].Id AND PermissionSet.Name IN: externalPS
                        ];
        }
        if(count > 0){
            objOutput.sRoleAssigned = 'Active';
            objOutputs.add(objOutput);
        }
        else{
            objOutput.sRoleAssigned = 'NoAccess';
            objOutputs.add(objOutput);
        }        
        return objOutputs;
    } 
}