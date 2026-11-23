global with sharing class UserCreationService {
    global static List<string> userUpdate() {
        List<string> username= new List<string>();
       Map<String,object> userData= (Map<String,object>) JSON.deserializeUntyped(RestContext.request.requestBody.toString());
        if(userData.get('uId')!=null){
            List<User> standardUsers = [select Id, Profile.UserType from User
                                        where Id = :(Id)userData.get('uId') and Profile.UserType = 'Standard'];
            Set<Id> standardUserIds = new Set<Id>();
            for (User u : standardUsers)
                standardUserIds.add(u.Id);
            
            List<UserLogin> userLogins = [select Id, UserId, IsFrozen from UserLogin where UserId in :standardUserIds];
            
        }
        //for(Map<String,object> user:userData){
            username.add((String)userData.get('uName'));
        //}
        
       return username;
}
}