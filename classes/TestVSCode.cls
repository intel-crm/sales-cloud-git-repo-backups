public with sharing class TestVSCode {
    public TestVSCode() {

    }
    public List<Contact> GetContacts() {

        return [select id from Contact limit 10];
        
    }
}