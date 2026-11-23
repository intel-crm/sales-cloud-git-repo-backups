/****************************************************************************************************************************************
* Class Name  : LessonlyUserCallouts 
* Version     : 1.0 
* Created Date: 06-16-2022
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Sandeep Joshi            06/16/2022            			  This class make Lessionly API call to get user detail and delete user
*****************************************************************************************************************************************/
public class LessonlyUserCallouts {
    //Unique label corresponding to the continuation
   public String requestLabel;
   public String result {get;set;}
   public List<Object> users {get;set;}
   
   public LessonlyUserCallouts(){ 
      users = new List<Object>();
   }
   
   //Make callout
   public Object  makeGetCallout() {
       Continuation con = new Continuation(40);
       con.continuationMethod='processResponse';
   
       Http http = new Http();
       HttpRequest request = new HttpRequest();
       request.setEndpoint('https://api.lessonly.com/api/v1/users?filter[email]=sandeep.joshi@intel.com');
          Blob headerValue = Blob.valueOf('inteldev:LWDfYbqDrHrQVs0rAMWKj8E4VVQK5jjP');
       //Blob headerValue = Blob.valueOf(username + ':' + password);
       String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
       request.setHeader('Authorization', authorizationHeader);
       request.setMethod('GET');
       //HttpResponse response = http.send(request);
       // Add callout request to continuation
       this.requestLabel = con.addHttpRequest(request);
       // Return the continuation
       return con; 
   }
   
   //Process HTTP Response
   public Object processResponse() {  
       HttpResponse response = Continuation.getResponse(this.requestLabel);
       System.debug('Header Data for you dear:'+  response.getBody());
       // Set the result variable that is displayed on the Visualforce page
       if (response.getStatusCode() == 200) {
           this.result = response.getBody();
           Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
           users = (List<Object>) results.get('users');
       }
       return null;
   }


}