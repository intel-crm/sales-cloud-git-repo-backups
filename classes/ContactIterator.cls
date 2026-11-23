global class ContactIterator implements Iterator<Contact>{ 

    List<Contact> lstCon {get; set;} 
    Integer j {get; set;} 
    ID contactRTId = schema.sobjecttype.Contact.getrecordtypeinfosbyname().get('Intel Contact').getRecordTypeId();
	public static Integer startInt=10000;
    public static Integer endInt=20000;
   global ContactIterator() { 
       lstCon = new List<Contact>();
       for(Integer i=startInt;i<=endInt;i++) {
           lstCon.add(new Contact(
               AccountId='0013F00000Bq6Ss',
               FirstName='Contact',
               LastName='Test'+i,
               email=i+'testcon@email.com',
               RecordTypeId=contactRTId
           ));
       }       
       j = 0; 
   }   

   global boolean hasNext(){ 
       if(j >= lstCon.size()) {
           return false; 
       } else {
           return true; 
       }
   }    

   global Contact next(){ 
       //if(i == 8){return null;} 
       j++; 
       return lstCon[j-1]; 
   } 
}