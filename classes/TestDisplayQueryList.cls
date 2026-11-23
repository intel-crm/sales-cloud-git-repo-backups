public with sharing class TestDisplayQueryList{
    public List<User> Records {get; set;}
    public TestDisplayQueryList(){
        Records =[SELECT Id, Username, Name From User Where Id IN(Select UserId FROM UserLogin WHERE IsFrozen = true) LIMIT 100];
    }
}