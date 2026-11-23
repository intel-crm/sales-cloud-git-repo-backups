@isTest
global class Core_User_Test {
  
   @istest static void TestTestUp()
    {
        try
        {
         /****   
           var appEvent = $A.get("e.force:switchApp");
    appEvent.setParams({
        "tabsetId": "02uU0000000DtzAIAS",
        "startUrl": "/one/one.app#/sObject/02uU0000000DtzAIAS"
    });
    appEvent.fire();

           ****/ 
            
            
              System.debug('Login  User ');
         // The following code runs as user u2.
         System.debug('Current Login User: ' + UserInfo.getUserName());
         System.debug('Current Login Profile: ' + UserInfo.getProfileId());
            
	  User u2 =[SELECT Id, name FROM user where name like '%BM Test User02%'];
      System.runAs(u2) {
           System.debug('Active  User ');
         // The following code runs as user u2.
         System.debug('Current User: ' + UserInfo.getUserName());
         System.debug('Current Profile: ' + UserInfo.getProfileId());
          
          
          
      }
        
         User u3 =[SELECT Id, name FROM user where name like '%IPA Ent111%' and IsActive = false];
      System.runAs(u3) {
           System.debug('InActive  User ');
         // The following code runs as user u2.
         System.debug('Current User: ' + UserInfo.getUserName());
         System.debug('Current Profile: ' + UserInfo.getProfileId());
          
          
          
      }
            
            
               User u4 =[SELECT Id, name FROM user where name like '%shijas%' ];
      System.runAs(u4) {
           System.debug('Active  User ');
         // The following code runs as user u2.
         System.debug('Current User: ' + UserInfo.getUserName());
         System.debug('Current Profile: ' + UserInfo.getProfileId());
          
          
          
      }
            
            
            
            
            
            
            
            
            
        }
            catch(exception ec)
            {
                System.debug('exception --------------------- ' + ec);
            }
            
	}
	  
}