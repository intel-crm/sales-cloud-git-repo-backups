/**
* @description       : 
* @author            : Deepthi Kambam
* @group             : Accenture
* @last modified on  : 20-09-2024
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/

public class Pricing_SW_RoleMapping {
    public class Response {
        @InvocableVariable
        public String message;
    }
    public static Map<String, List<String>> roleToPermissionSetMap = new Map<String, List<String>>{
        'Software CPQ User' => new List<String>{'Pricing_SW_CPQ_License', 'Pricing_SW_CPQ_AA_License','Pricing_SW_CPQ_User'},
         'Software CPQ Level1 Approvers' => new List<String>{'Pricing_SW_CPQ_License', 'Pricing_SW_CPQ_AA_License','Pricing_SW_CPQ_Approver_User'},
         'Software CPQ Level2 Approvers' => new List<String>{'Pricing_SW_CPQ_License', 'Pricing_SW_CPQ_AA_License','Pricing_SW_CPQ_Approver_User'}, 
         'Software CPQ Level3 Approvers' => new List<String>{'Pricing_SW_CPQ_License', 'Pricing_SW_CPQ_AA_License','Pricing_SW_CPQ_Approver_User'},
         'Software CPQ Level4 Approvers' => new List<String>{'Pricing_SW_CPQ_License', 'Pricing_SW_CPQ_AA_License','Pricing_SW_CPQ_Approver_User'},
         'Software CPQ Level5 Approvers' => new List<String>{'Pricing_SW_CPQ_License', 'Pricing_SW_CPQ_AA_License','Pricing_SW_CPQ_Approver_User'},
         'Software CPQ Read' => new List<String>{'Pricing_SW_CPQ_License', 'Pricing_SW_CPQ_AA_License','Pricing_SW_CPQ_Read_Access'},
         'Software CPQ Read All' => new List<String>{'Pricing_SW_CPQ_License', 'Pricing_SW_CPQ_AA_License','Pricing_SW_CPQ_Read_Access'},
         'Software CPQ Custom Workload Approver' => new List<String>{'Pricing_SW_CPQ_License','Pricing_SW_CPQ_Custom_Workload_Approver'}
            };
    public static Map<String, List<String>> roletoPublicGroupMap = new Map<String, List<String>>{
        'Software CPQ User' => new List<String>{'Pricing_SW_CPQ_User','Pricing_SW_CPQ_All_Internal_Users'},
        'Software CPQ Level1 Approvers' => new List<String>{'Pricing_SW_Level_1_Approvers','Pricing_SW_CPQ_All_Internal_Users'},
        'Software CPQ Level2 Approvers' => new List<String>{'Pricing_SW_Level_2_Approvers','Pricing_SW_CPQ_All_Internal_Users'},
        'Software CPQ Level3 Approvers' => new List<String>{'Pricing_SW_Level_3_Approvers','Pricing_SW_CPQ_All_Internal_Users'},
        'Software CPQ Level4 Approvers' => new List<String>{'Pricing_SW_Level_4_Approvers','Pricing_SW_CPQ_All_Internal_Users'},
        'Software CPQ Level5 Approvers' => new List<String>{'Pricing_SW_Level_5_Approvers','Pricing_SW_CPQ_All_Internal_Users'},
        'Software CPQ Read' => new List<String>{'Pricing_SW_CPQ_Read_Access','Pricing_SW_CPQ_All_Internal_Users'},
        'Software CPQ Read All' => new List<String>{'Pricing_SW_CPQ_Read_All_Access','Pricing_SW_CPQ_All_Internal_Users'},
        'Software CPQ Custom Workload Approver' => new List<String>{'Pricing_SW_CPQ_Custom_wrkld_Approver','Pricing_SW_CPQ_All_Internal_Users'}
      };
    
    @InvocableMethod
    public static List<Response> assignPermissionsAndGroups(List<InputVariables> variables) {
	  List<Response> responses = new List<Response>();
        for(InputVariables var : variables){
		      Response res = new Response();
			  String finalMessage = '';
              if (var.userId.length() != 18) {
                   finalMessage += 'User ID "' + var.userId + '" is not valid. It must be 18 characters.\n';
        } else {
                if (!roleToPermissionSetMap.containsKey(var.roleName) && !roleToPublicGroupMap.containsKey(var.roleName)) {
                    finalMessage += 'Role name "' + var.roleName + '" is not valid.\n';
                } else {
                    List<User> users = [SELECT Id, IsActive FROM User WHERE Id =: var.userId LIMIT 1];
                    User inactiveUser = users[0];
                    if (users.isEmpty() || !inactiveUser.isActive) {
                        System.debug('Inactive User RCB'+ inactiveUser.isActive);
                        finalMessage += 'User ID "' + var.userId + '" is not active.\n';
                        System.debug('Final Message'+finalMessage);
                       // finalMessage += 'User Id is not active.\n';
                    } else {
                        User activeUser = users[0];
                        if (activeUser.IsActive) {
                            String permissionMessage = assignPermissionSets(var.userId, var.roleName);
                            finalMessage += permissionMessage;

                            String groupMessage = assignPublicGroups(var.userId, var.roleName);
                            finalMessage += groupMessage;
                        } 
                    }
                }
             
        }
        res.message = finalMessage;
        responses.add(res);
    }
        return responses;
     }
   
	public static String assignPermissionSets(String userid, String roleName){
       String message = '';
	   if (roleToPermissionSetMap.containsKey(roleName)) {
            List<String> permissionSetNames = roleToPermissionSetMap.get(roleName);
            for (String permissionSetName : permissionSetNames) {
               System.debug('Permissionset'+permissionSetNames);
               PermissionSet permissionSet = [SELECT Id FROM PermissionSet WHERE Name =: permissionSetName];
               if (permissionSet != null) {
 
                     List<PermissionSetAssignment> existingAssignments = [
                          SELECT Id
                          FROM PermissionSetAssignment
                          WHERE AssigneeId =: userId
                          AND PermissionSetId =: permissionSet.Id
                          ];
 
                     if (existingAssignments.isEmpty()) {
                     
                         PermissionSetAssignment permAssign = new PermissionSetAssignment(
                         AssigneeId = userId,
                         PermissionSetId = permissionSet.Id
                          );
                        insert permAssign;  
                        message += '"' + permissionSetName + '" Permission Set is assigned successfully.\n ';
            } 
			else {
                message += '"' + permissionSetName + '" Permission Set is already assigned to the user.\n';
            }
        } else {
            message += '"' + permissionSetName + '" Permission Set not found with the provided API name.\n';
        }
		}
      }
       return message;
     }
        
    public static String assignPublicGroups(String userId, String roleName) {
        String message = '';
        if (roleToPublicGroupMap.containsKey(roleName)) {
            List<String> groupNames = roleToPublicGroupMap.get(roleName);
            for (String groupName : groupNames) {
                Group publicGroup = [SELECT Id FROM Group WHERE Type = 'Regular' AND DeveloperName = :groupName];
                 if (publicGroup != null) {
                     List<GroupMember> existingGroupMembership = [
                          SELECT Id
                          FROM GroupMember
                          WHERE GroupId =: publicGroup.Id
                          AND UserOrGroupId =: userId
                          ];
                     if (existingGroupMembership.isEmpty()) {
                 
                           GroupMember gm = new GroupMember(
                                GroupId = publicGroup.Id,
                                UserOrGroupId = userId
                            );
                           insert gm;
						   message += 'User added to Public Group "' + groupName + '" successfully.\n';
                     } else {
						 message += 'User is already added to Public Group "' + groupName + '".\n';
                     }
                }
               else {
					message += 'Public Group "' + groupName + '" not found.\n';
                }
              }
            }
       else {
			message += 'No Public Groups found for role: "' + roleName +'".\n';
        }
     return message;
     }
     public class InputVariables{
        @InvocableVariable(label='User Id' required=true)
        public String userId;
        @InvocableVariable(label='Role Name' required=true)
        public String roleName;
        
    }
}