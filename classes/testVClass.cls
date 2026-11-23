public class testVClass {
	 @AuraEnabled
    public static List<Id> getUserList(){
        //List<Id> userList = [Select id,Name from user where ID IN ('005g0000006nb3o','005g00000079Sql')];
        List<Id> userIdList = new List<Id>();
        userIdList.add('005g0000006nb3o');
        userIdList.add('005g00000079Sql');
        
        
        return userIdList;
    }
}