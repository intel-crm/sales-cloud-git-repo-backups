public class AuthHelper {   
    // Method to stub
    /*public String getTodaysDate() {
        return Date.today().format();
    }*/
    public Map<String, String> getAuthSession() {
        return Auth.SessionManagement.getCurrentSession();
    }
}