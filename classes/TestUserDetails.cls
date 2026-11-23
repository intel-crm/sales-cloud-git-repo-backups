public class TestUserDetails {
    public User usr {get;set;}
    public TestUserDetails(){
       usr=[select firstname,lastname,Email from user where id=:ApexPages.currentPage().getParameters().get('id')];
    }
    
}